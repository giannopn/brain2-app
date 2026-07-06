import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const receiptsBucket = 'receipts';

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

function errorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  return String(error);
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse({ error: 'Delete account function is not configured' }, 500);
  }

  const authHeader = req.headers.get('Authorization');
  const token = authHeader?.startsWith('Bearer ')
    ? authHeader.replace('Bearer ', '')
    : null;

  if (!token) {
    return jsonResponse({ error: 'Missing authorization token' }, 401);
  }

  const body = await req.json().catch(() => null);
  if (body?.confirmed !== true) {
    return jsonResponse({ error: 'Account deletion was not confirmed' }, 400);
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });

  try {
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser(token);

    if (userError || !user) {
      return jsonResponse({ error: 'Invalid or expired session' }, 401);
    }

    const userId = user.id;
    const receiptPaths = await listStoragePaths(supabase, userId);

    for (let i = 0; i < receiptPaths.length; i += 100) {
      const batch = receiptPaths.slice(i, i + 100);
      const { error } = await supabase.storage.from(receiptsBucket).remove(batch);
      if (error) throw new Error(`Failed to delete receipt files: ${error.message}`);
    }

    await deleteRows(supabase, 'bill_transactions', 'user_id', userId);
    await deleteRows(supabase, 'bill_categories', 'user_id', userId);
    await deleteRows(supabase, 'profiles', 'id', userId);

    const { error: deleteUserError } = await supabase.auth.admin.deleteUser(userId);
    if (deleteUserError) {
      throw new Error(`Failed to delete auth user: ${deleteUserError.message}`);
    }

    return jsonResponse({
      ok: true,
      deletedReceiptFiles: receiptPaths.length,
    });
  } catch (error) {
    console.error('delete-account failed:', error);
    return jsonResponse({ error: errorMessage(error) }, 500);
  }
});

async function deleteRows(
  supabase: ReturnType<typeof createClient>,
  table: string,
  column: string,
  userId: string,
): Promise<void> {
  const { error } = await supabase.from(table).delete().eq(column, userId);
  if (error) throw new Error(`Failed to delete ${table}: ${error.message}`);
}

async function listStoragePaths(
  supabase: ReturnType<typeof createClient>,
  prefix: string,
): Promise<string[]> {
  const { data, error } = await supabase.storage
    .from(receiptsBucket)
    .list(prefix, {
      limit: 1000,
      sortBy: { column: 'name', order: 'asc' },
    });

  if (error) throw new Error(`Failed to list receipt files: ${error.message}`);

  const paths: string[] = [];

  for (const item of data ?? []) {
    const itemPath = `${prefix}/${item.name}`;
    const isFolder = item.id === null || item.metadata === null;

    if (isFolder) {
      paths.push(...await listStoragePaths(supabase, itemPath));
    } else {
      paths.push(itemPath);
    }
  }

  return paths;
}
