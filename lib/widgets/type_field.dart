import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable typing field with variants for normal, focused, error, and disabled states.
/// Supports prefix/suffix icons, helper or error text, and optional obscure toggle.
class TypeField extends StatefulWidget {
  const TypeField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.keyboardType,
    this.obscureText = false,
    this.enableObscureToggle = false,
    this.maxLines = 1,
    this.maxLength,
    this.showLabel = true,
    this.inputFormatters,
    this.textAlign = TextAlign.left,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 16,
    ),
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enableObscureToggle;
  final int maxLines;
  final int? maxLength;
  final bool showLabel;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final EdgeInsets contentPadding;

  @override
  State<TypeField> createState() => _TypeFieldState();
}

class _TypeFieldState extends State<TypeField> {
  static const _bgColor = Color(0xFFF1F1F1);
  static const _borderNormal = Color(0xFFDADADA);
  static const _borderFocus = Color(0xFF007AFF);
  static const _borderError = Color(0xFFFF3B30);
  static const _textColor = Color(0xFF000000);
  static const _hintColor = Color(0xFF9E9E9E);
  static const _helperColor = Color(0xFF666666);

  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _hasFocus = false;
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _hasFocus = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocus() {
    if (!mounted) return;
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  Color _currentBorderColor() {
    if (!widget.enabled) return _borderNormal;
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      return _borderError;
    }
    if (_hasFocus) return _borderFocus;
    return _borderNormal;
  }

  Color _currentLabelColor() {
    if (!widget.enabled) return _hintColor;
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      return _borderError;
    }
    return _textColor;
  }

  Widget? _buildSuffix() {
    if (widget.enableObscureToggle) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off : Icons.visibility,
          color: _hintColor,
          size: 20,
        ),
        onPressed: widget.enabled
            ? () {
                setState(() {
                  _obscured = !_obscured;
                });
              }
            : null,
      );
    }
    return widget.suffix;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _currentBorderColor();
    final suffix = _buildSuffix();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _currentLabelColor(),
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : _bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.3),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.prefix != null) ...[
                const SizedBox(width: 12),
                widget.prefix!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  obscureText: _obscured,
                  inputFormatters: widget.inputFormatters,
                  textAlign: widget.textAlign,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: _textColor,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    isDense: true,
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: _hintColor,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    contentPadding: widget.contentPadding,
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 10),
                suffix,
                const SizedBox(width: 12),
              ],
            ],
          ),
        ),
        if ((widget.errorText != null && widget.errorText!.isNotEmpty) ||
            (widget.helperText != null && widget.helperText!.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.errorText?.isNotEmpty == true
                  ? widget.errorText!
                  : (widget.helperText ?? ''),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: widget.errorText?.isNotEmpty == true
                    ? _borderError
                    : _helperColor,
              ),
            ),
          ),
      ],
    );
  }
}
