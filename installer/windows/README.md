# Windows Installer

使用 Inno Setup 从 Flutter Windows release 目录生成安装器。

## 依赖

- `flutter build windows --release`
- `iscc` 命令可用

## 打包

```bash
iscc installer/windows/waternode.iss
```

输出文件：

- `dist/windows/WaterNode Setup.exe`
