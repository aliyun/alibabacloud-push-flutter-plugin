# AGENTS.md

## 代码 CR 规则

- 需要阅读所有变更的代码前后的完整源文件，避免不相关的文件变更
- 给出代码变更的主要目的和其他一些更改
- 对于高风险的代码变更给出特别关注
- 代码对比分支为 master 分支，CR 之前保证两个分支为最新远程分支

## 版本发布工作流程

本项目有两个远程仓库：

- `origin`：阿里内网仓库
- `github`：GitHub 公开仓库 aliyun/alibabacloud-push-flutter-plugin

### 1. 创建 dev 分支

从 master 分支创建 dev 分支，分支命名格式为 `dev_x.y.z`：

```bash
git checkout -b dev_x.y.z master
git push -u origin dev_x.y.z
```

### 2. 更新版本号

修改 `pubspec.yaml` 中的 `version` 字段为目标版本号。

### 3. 构建验证

使用 FVM 确保 Flutter 版本一致（项目锁定 3.19.6）：

```bash
fvm flutter pub get
cd example
fvm flutter build apk --debug
fvm flutter build ios --no-codesign
```

确认 Android 和 iOS 构建均成功。

### 4. 发布到 pub.dev

```bash
fvm flutter pub publish --dry-run
```

确认无错误后正式发布：

```bash
fvm flutter pub publish
```

发布目标为 https://pub.dev/packages/aliyun_push ，access 为 public。

### 5. 提交版本变更

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: release x.y.z"
git push origin dev_x.y.z
```

### 6. 合并回 master

在内网仓库将 `dev_x.y.z` 合并到 `master` 分支。

### 7. 在 master 上打 tag

合并完成后，在 master 分支的合并提交上打 tag：

```bash
git checkout master
git pull origin master
git tag x.y.z
git push origin x.y.z
```

### 8. 同步到 GitHub

```bash
git push github master
git push github x.y.z
```

确保 GitHub 公开仓库的 master 分支和 tag 与内网保持同步。
