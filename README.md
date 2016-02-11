## 各種opensourceライブラリを vc でビルドするためのバッチ

vc 対応の opensource ライブラリのいくつかを まとめてビルドするための
バッチ群。
(ざっくり boost wxWidgets libzlib bzip2 libpng libjpg libtiff ...)

配布元のlibバイナリや、ライブラリのデフォルトの設定でコンパイルした場合
Cランタイム(crt) が static か dll使用(msvcrt*.dll) かマチマチだったり、
また(c++ の場合) 異なるバージョンの vc++ でコンパイルしたライブラリの
リンクが弾かれることがあったりと配布ままのバイナリが使えないことが
ありソースをビルドするはめになるが細々面倒なもので...

boost のように ランタイムのstatic/dll, ライブラリ自身のstatic/dll 対応
別にファイル名を変えてくれるものもあるが、debug/releaseの区別なくソース
フォルダに１つ(1式)生成するだけのものも多いので、そういうビルド＆フォルダ
仕訳を楽にするために作業バッチ化.


## 方針

-展開したライブラリ・ソース中のファイルを編集しない。
が、ライブラリの出力先等、そのフォルダ内にファイルの追加は有.
また、Makefileに対し引数でオプション設定変更したりは当然する.

-一応バッチのライセンスは boost software license version 1.0 という
ことにしとく(当然 各ライブラリのライセンスはそれぞれ)

- ライブラリを貯めるディレクトリを用意し、そこに各種ライブラリを
展開しておき、バッチでビルド。生成されたライブラリは、基本的には
ソース環境のまま利用(ヘッダ・ファイルをそのまま使う).
ただファイル数個の単機能ライブラリは、名前が衝突しない範囲で
ある程度 ひとまとめにする.

- vcのバージョンは１種類のみを前提. 別のバージョン用をビルド
する場合は 別ディレクトリで同様に用意.
※ フォルダ名に vcバージョンを含めると、利用側でのコンパイラ名対応
がちょっと面倒、と、いう考え.


## インストール

- まず 各種ライブラリをまとめて置くフォルダを用意する.
仮にここでは d:\libs_vc\ としておく.

- そのフォルダ(d:\libs_vc\) の直下に この
  bld_lib_bat\
を配置.(d:\libs_vc\bld_lib_bat\)

- bld_lib_bat\ にある libs_config.bat.source をコピーして
    bld_lib_bat\libs_config.bat
  を作成。
  エディタで開け、
	set CcName=vc8～vc12	 						使用するvcコンパイラ.
	set CcHasX64=0 or 1	    						x86のみなら 0, x64版もビルドするなら 1
    set CcNoRtStatic=0 or 1                         staticランタイム版を生成しない場合 1を設定(vc++Expressでは必須)
	set CcCMakeDir=%ProgramFiles(x86)%\CMake\bin	libjpeg-turbo や glfw 等cmakeを使う場合, cmakeのディレクトリを設定.
	set CcNasmDir=c:\tools\nasm						libjpeg-turbo 等 nasm を使う場合、nasmのディレクトリを設定.
  を自身の環境に合わせて書き換える.
  ※ その他 Cc???? はバッチ共通で使うデフォルト値


- ビルドしたいライブラリを入手(ダンロード)して
d:\libs_vc\ の直下に解凍.
フォルダ名はバージョン番号等含んだデフォルトのままのこと.
たとえば zlib だと zlib128.zip を入手＆解凍、
  d:\libs_vc\zlib-1.2.8
が出来る.
d:\libs_vc\bld_lib_bat\ をカレント・ディレクトリにして
  bld_zlib.bat
を実行.
  d:\libs_vc\misc_inc\
にヘッダ zlib.h が生成され(作られた zlib.h は zlib-1.2.8\ 
にある本物のzlib.h をincludeするだけのラッパー)
  d:\libs_vc\misc_lib\vc_x86
  d:\libs_vc\misc_lib\vc_x86_debug
  d:\libs_vc\misc_lib\vc_x86_rtdll
  d:\libs_vc\misc_lib\vc_x86_rtdll_debug
  d:\libs_vc\misc_lib\vc_x86
  d:\libs_vc\misc_lib\vc_x86_debug
  d:\libs_vc\misc_lib\vc_x86_rtdll
  d:\libs_vc\misc_lib\vc_x86_rtdll_debug
に zlib.lib が生成される.
※ ターゲットディレクトリ名はzlib*のように指定して最初に見つかった
   適当なモノが使われる状態なので、複数のバージョンをそのまま置かないこと.
