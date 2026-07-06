# delete-account

Supabase Edge Function used by the Flutter app account deletion flow.

Deploy it to the same Supabase project used in `lib/main.dart`:

```bash
supabase login
supabase link --project-ref rowicwwvaxcohuuhubqu
supabase functions deploy delete-account
```

The function uses Supabase runtime environment variables:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Do not put the service role key in Flutter/mobile code.
