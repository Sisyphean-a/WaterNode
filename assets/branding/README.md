# WaterNode Branding Assets

`waternode_icon.svg` 是品牌主源文件，表达“水滴 + 节点”的图标语义。

本目录下的位图资源与平台图标均由下列脚本生成：

```bash
python tool/generate_brand_assets.py
```

生成后会同步更新：

- `assets/branding/waternode_icon.png`
- `windows/runner/resources/app_icon.ico`
- `android/app/src/main/res/mipmap-*/ic_launcher.png`

如需改图标，优先修改 SVG 或脚本中的几何参数，不要手工逐个改平台产物。
