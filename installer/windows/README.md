# Windows Installer

使用 Inno Setup 从 Flutter Windows release 目录生成安装器。

## 依赖

- `flutter build windows --release --split-debug-info=build/symbols/windows`
- `iscc` 命令可用

## 打包

```bash
iscc installer/windows/waternode.iss
```

输出文件：

- `dist/windows/WaterNode Setup.exe`

脚本默认开启：

- `lzma2/ultra64` 高压缩
- 排除 `.pdb` / `.lib` / `.exp` / `.ilk` 非运行时文件
- `build/symbols/windows/` 保留在构建机，用于发布后还原 Dart 堆栈
