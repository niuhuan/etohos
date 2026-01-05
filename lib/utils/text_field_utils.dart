import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';

/// 应用内剪贴板管理器（使用变量存储，不依赖系统剪贴板）
/// 用于鸿蒙等不支持系统剪贴板的平台
class AppClipboard {
  static String _clipboardData = '';

  /// 将文本复制到应用剪贴板
  static void setData(String text) {
    _clipboardData = text;
  }

  /// 从应用剪贴板获取文本
  static String getData() {
    return _clipboardData;
  }

  /// 检查剪贴板是否有内容
  static bool hasData() {
    return _clipboardData.isNotEmpty;
  }

  /// 清空剪贴板
  static void clear() {
    _clipboardData = '';
  }
}

/// 统一的文本输入框上下文菜单构建器
/// 完全由 Flutter 自己维护，不依赖系统菜单
/// 使用应用内剪贴板，支持复制、粘贴、剪切、全选等标准操作
Widget buildDefaultContextMenu(BuildContext context, EditableTextState editableTextState) {
  final TextEditingValue value = editableTextState.currentTextEditingValue;
  final bool hasSelection = value.selection.isValid && !value.selection.isCollapsed;
  final String selectedText = hasSelection 
      ? value.selection.textInside(value.text)
      : '';

  // 构建子组件列表
  final List<Widget> children = [];
  
  // 复制按钮（仅在有选择时显示）
  if (hasSelection) {
    children.add(
      TextSelectionToolbarTextButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onPressed: () {
          // 使用应用内剪贴板
          AppClipboard.setData(selectedText);
          editableTextState.copySelection(SelectionChangedCause.toolbar);
          editableTextState.hideToolbar();
        },
        child: Text(t('copy')),
      ),
    );
  }
  
  // 剪切按钮（仅在有选择时显示）
  if (hasSelection) {
    children.add(
      TextSelectionToolbarTextButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onPressed: () {
          // 使用应用内剪贴板
          AppClipboard.setData(selectedText);
          editableTextState.cutSelection(SelectionChangedCause.toolbar);
          editableTextState.hideToolbar();
        },
        child: Text(t('cut')),
      ),
    );
  }
  
  // 粘贴按钮（仅在剪贴板有内容时显示）
  if (AppClipboard.hasData()) {
    children.add(
      TextSelectionToolbarTextButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onPressed: () {
          // 从应用内剪贴板获取数据并粘贴
          final clipboardText = AppClipboard.getData();
          final newText = value.text.replaceRange(
            value.selection.start,
            value.selection.end,
            clipboardText,
          );
          editableTextState.userUpdateTextEditingValue(
            TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(
                offset: value.selection.start + clipboardText.length,
              ),
            ),
            SelectionChangedCause.toolbar,
          );
          editableTextState.hideToolbar();
        },
        child: Text(t('paste')),
      ),
    );
  }
  
  // 全选按钮（仅在文本不为空时显示）
  if (value.text.isNotEmpty) {
    children.add(
      TextSelectionToolbarTextButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onPressed: () {
          editableTextState.selectAll(SelectionChangedCause.toolbar);
          editableTextState.hideToolbar();
        },
        child: Text(t('select_all')),
      ),
    );
  }

  // 如果没有可用的操作，隐藏工具栏而不是创建空的工具栏
  if (children.isEmpty) {
    return const SizedBox.shrink();
  }

  return TextSelectionToolbar(
    anchorAbove: editableTextState.contextMenuAnchors.primaryAnchor,
    anchorBelow: editableTextState.contextMenuAnchors.secondaryAnchor ?? editableTextState.contextMenuAnchors.primaryAnchor,
    children: children,
  );
}

/// 文本输入框的通用配置
class TextFieldConfig {
  /// 是否启用交互式选择（允许选择和复制）
  static const bool enableInteractiveSelection = true;

  /// 文本大小写设置（禁用自动大写）
  static const TextCapitalization textCapitalization = TextCapitalization.none;

  /// 上下文菜单构建器
  static Widget Function(BuildContext, EditableTextState) get contextMenuBuilder => buildDefaultContextMenu;
}

