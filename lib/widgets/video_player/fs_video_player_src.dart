abstract class FsVideoPlayerSrc {
  FsVideoPlayerSrc();

  String getSrc();
}

class FsVideoPlayerUrlSrc implements FsVideoPlayerSrc {
  final String url;

  FsVideoPlayerUrlSrc(this.url);

  @override
  String getSrc() => url;
}

class FsVideoPlayerFileSrc implements FsVideoPlayerSrc {
  final String path;

  FsVideoPlayerFileSrc(this.path);

  @override
  String getSrc() => path;
}

class FsVideoPlayerFileAssetsSrc implements FsVideoPlayerSrc {
  final String path;

  FsVideoPlayerFileAssetsSrc(this.path);

  @override
  String getSrc() => path;
}
