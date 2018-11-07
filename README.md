## 各種opensourceライブラリを vc でビルドするためのバッチ

vc 対応の opensource ライブラリのいくつかを まとめてビルドするためのバッチ群。

boost のように ランタイムのstatic/dll, ライブラリ自身のstatic/dll 対応
別にファイル名を変えてくれるものもあるが、debug/releaseの区別なくソース
フォルダに１つ(1形式)生成するだけのものも多く、
配布元のlibバイナリや、ライブラリのデフォルトの設定だと
Cランタイム(crt) が static か dll使用(msvcrt*.dll) かマチマチだったり、
また(c++ の場合) 異なるバージョンの vc++ でコンパイルしたライブラリの
リンクができないなど不便なので、 

弾かれることがあったりと配布ままのバイナリが使えないことが多いため用意。


いので、そういうビルド＆フォルダ
仕訳を多少楽にするためにバッチ化。

vc8～vc14.1が対象...だが 今は vc14.1 が主で、他のverはどうなっているか不明。
(当初は vc9,vc12 あたりを主で用いていた)
(そもそもライブラリ・ビルドして力尽きて満足しちまってるような……)  


## コンパイルするライブラリ

大きめのライブラリ
- 現状 boost, OpenCV, wxWidgets, fltk  
これらは、それらの標準のincludeやlibのパスを使う。

比較的小さいライブラリ
- 現状 zlib, libbz2, libpng, mozjpeg(jpeglib, libjpeg-turbo), libtiff, libharu,
glfw3, libogg, libvorbis, openssl, pixman, cairo  
これらは misc_inc/ , misc_lib/ ディレクトリにも、まとめる。


## 方針

- 極力、展開したライブラリ・ソース中のファイルを編集しない。
が、ライブラリの出力先等、そのフォルダ内にファイルの追加は有。
また、Makefileに対し引数でオプション設定変更したりは当然する。
(極稀にどうしてもソース修正の必要なモノ有り)

- ライブラリを貯めるディレクトリを用意し、そこに各種ライブラリを
展開しておき、バッチでビルド。生成されたライブラリは、基本的には
ソース環境のまま利用(ヘッダ・ファイルをそのまま使う)。

- ただし生成されたライブラリは、vcバージョン, debug|release,
static|dllランタイム, 等の都合でフォルダ分けし直している。
その生成するライブラリディレクトリ名は Visual Studio での
指定でなるべく変数を使えるようにする。

- 基本的に各ライブラリのディレクトリままの利用を想定だが、
数が増えると利用時の指定が面倒なので、ファイル数の少ないライブラリに
関しては　misc_inc/, misc_lib/ というディレクトリにも まとめている。

- ターゲットライブラリはdll化せずstaticリンクしての利用を想定。
ターゲットライブラリ自身のdll版は、ビルドに用意されていれば一応ビルドしているが、
使ったこと無いので具合は不明。(が用意されていないターゲットも多いので...)

- 一応バッチのライセンスは boost software license version 1.0 という
ことにしとく(当然 各ライブラリのライセンスはそれぞれ)


## インストール

- まず 各種ライブラリをまとめて置くフォルダを用意する。
仮にここでは、コンパイラとしてvc14.1(vs2017)を使い、まとめ置きディレクトリを
d:/libs_vc/ とする。

- そのフォルダ(d:/libs_vc/) の直下に この  
  bld_lib_bat/  
を配置。(d:/libs_vc/bld_lib_bat/)

- bld_lib_bat/ にある libs_config.bat.source をコピーして  
        bld_lib_bat/libs_config.bat  
  を作成。  
  エディタで開け、  
  
        set CcName=vc141 (vc80～vc141のいずれか)       　　使用するvcコンパイラ  
        set CcHasX86=0 or 1                            　　x86用を生成する場合1
        set CcHasX64=0 or 1                            　　x64用を生成する場合1
        set CcNoRtStatic=0 or 1                        　　staticランタイム版を生成しない場合 1を設定  
        set CcCMakeDir=%ProgramFiles%\CMake\bin        　　cmake.exeのあるディレクトリ  
        set CcNasmDir=%USERPROFILE%\AppData\Local\bin\nasm nasm.exe のあるディレクトリ  
        set CcPerlDir=c:\Perl64\site\bin;c:\Perl64\bin 　　perl.exe のあるディレクトリ  
        set CcPython3Path=……                         　　python.exe のあるディレクトリ  
		set CcWinGnuMake=……                          　　mingw32-make.exe(mozmake.exe)へのパス  
        set CcMsys1Paths=…\msys\local\bin;…\msys\bin 　　msys1 のパス  
  
  - vcバージョン名は VSのマクロ変数$(PlatformToolsetVersion) の値が使えるように
    vc9やvc12でなくvc90やvc120のように記述するようにしている。
  - vc++ express版の場合はCcHasX64=0、CcNoRtStatic=0にすることになる
    (expressでのビルドは未確認。vs2013以降のフリー版は x64 も staticランタイムも使えるので)
  - libjpeg-turbo や glfw, opencv 等は cmakeを使うので予めインストールし、ここにそのディレクトリを記述。
    win64環境で cmakeのインストーラで入れたならこのままでいいはず。
  - libjpeg-turbo や openssl 等 nasm を使う場合は nasm のディレクトリを設定。
    nasmをインストーラで入れたならこのままでいいはず。
  - openssl 等 perl を使う場合は perl のディレクトリを設定。
    例はWin64用ActivePerl のdefaultの場合。 
  - pixman のビルドでは CcWinGnuMake= に mingw32-make あるいは mozilla-build の mozmake.exe を設定。
    mozilla-build をインストールしていた場合はこのままでいいはず。
  - cairo のビルドでは CcMsys1Paths= に msys1 か mozilla-build のlocal/bin,binのパスを設定
    mozilla-build をインストールしていた場合はこのままでいいはず。
  - CcCMakeDir,CcNasmDir,CcPerlDir等を使用しない場合でフォルダが存在しない場合は空にしておくこと。
  - その他 同一ファイル内にある Cc???? はバッチ共通で使うデフォルト値。


- ビルドしたいライブラリを入手(ダンロード|clone)して d:/libs_vc/ の直下に解凍。  
  ダウンロード物のフォルダ名はバージョン番号等含んだデフォルトのままを想定。  
  たとえば zlib だと zlib128.zip を入手＆解凍、  
      d:/libs_vc/zlib-1.2.8  
  が出来る。あるいは git リポジトリを clone して zlib ままでも。  
  ※ gitリポジトリで作業したものは dl_zlib.bat のようにバッチ用意。  
  d:/libs_vc/bld_lib_bat/ をカレント・ディレクトリにして  
      bld_zlib.bat  
  を実行。  
      d:/libs_vc/misc_inc/  
  にヘッダ zlib.h が生成され
  (作られた zlib.h は zlib-1.2.8 にある本物のzlib.h をincludeするだけのラッパー)  
      d:/libs_vc/misc_lib/vc120_Win32_release  
      d:/libs_vc/misc_lib/vc120_Win32_debug  
      d:/libs_vc/misc_lib/vc120_Win32_static_release  
      d:/libs_vc/misc_lib/vc120_Win32_static_debug  
      d:/libs_vc/misc_lib/vc120_x64_release  
      d:/libs_vc/misc_lib/vc120_x64_debug  
      d:/libs_vc/misc_lib/vc120_x64_static_release  
      d:/libs_vc/misc_lib/vc120_x64_static_debug  
  等に zlib.lib が生成される。  
  ※ ターゲットディレクトリ名はzlib*のように指定して、名前ソートで最後に見つかった
     モノを使うが、わかりにくいので複数のバージョンを置くのは避けたほうがよいだろう。
  
  一度ビルドを始めると、x86,x64のdllランタイム版&static版をdebug&release共にビルド(計8種類)
  をビルドをするので、かなり時間がかかることが多いので余裕のあるときに行うこと。


## misc_inc

misc_inc/ には、各ライブラリのヘッダをコピーしている。
元々からサブディレクトリなものもあれば、量の多いものはサブディレクトリにしているものもある。  

これを使えというわけでなく利用の一手段として。


## 生成するライブラリについて、misc_lib/ について

boostやwxWidgetsのように元から仕分け対応済のモノもあるが、debug|release、static|dll 等の
設定違い別にディレクトリを変えたり名前を変えたりしていないライブラリも多々あるため、
仕分け対応していないライブラリについては、このバッチ群独自にディレクトリ分けしている。

libs_vc??/misc_lib/ に入るものについては、
- vc120_Win32_release
- vc120_Win32_debug
- vc120_Win32_static_release
- vc120_Win32_static_debug
- vc120_x64_release
- vc120_x64_debug
- vc120_x64_static_release
- vc120_x64_static_debug
  
のようになる。  

ディレクトリ分けされてない各ライブラリのビルドについても似たような感じでディレクトリ分けしている。
（このへんはライブラリごとに事情が違うので、ビルド後のディレクトリを確認のこと)
  
先頭にはまず使用するVCのバージョン名がつく。vc10からの Visual Studio の
マクロ変数 $(PlatformToolsetVersion) の値が使えるように vc10 や vc12 でなく vc90 や vc120 のように
記述するようにしている。
次に _static があれば static ランタイム版で(なければdllランタイム:msvcrt???.dllを使う)、
最後に _release | _debug ビルドを表している。  
  
vc10 以降ならば Visual Studio の追加のライブラリの欄に  
  (ディレクトリ…)/libs_vc/misc_lib/vc$(PlatformToolsetVersion)_$(PlatformName)_$(Configuration)  
  や  
  (ディレクトリ…)/libs_vc/misc_lib/vc$(PlatformToolsetVersion)_$(PlatformName)_static_$(Configuration)  
の感じに追加するのを想定。 
static版でも、ソリューション構成側で static_release, static_debug を用意している場合は最初の指定でよいだろう。

vc9以前の場合は $(Configuration) でなく $(ConfigurationName) を使う必要あり。
また、$(PlatformToolsetVersion) がないので直接vc90のように記述するか、
vsのプロパティシートでユーザー定義マクロとして PlatformToolsetVersion を設定することになる。

生成される各ライブラリのファイル名は、なるべく元のビルドのままにしたかったが、
debugビルドやランタイムの区別のため、元とは違うポストフィックス(_debugや_static)を
つけている場合もある。 実際に生成されたファイル名を確認のこと。

dllライブラリ版は用意されている場合は、staticライブラリ版を別名で生成していて _static や -static が
後ろについていることも多そう。なので、そうでないものもそれに倣った。
  
※紛らわしいが、ディレクトリ名のstatic はランタイムを表し、ライブラリファイル名に付く
staticはターゲットライブラリがstaticリンクであることを表している。
  
※ 生成ディレクトリ名を調整(変更)したい場合は libs_config.bat を弄る。
たとえば vcバージョン名を付けたくなければ CcNamePrefix を  
    set CcLibPrefix=  
のように空に設定。 


## makefileやvcxproj等に対する文字列置換

ものによっては、makefile や sln,vcxproj ファイルの特定の文字列を置換したファイルを生成する必要があり、
cmd.exeの置換機能では対処しきれないケースもあったため、簡易なテキスト置換ツール
  tiny_replstr(.cpp)
を バッチ実行時に(未生成なら)コンパイルして使用している。


## bld1_????.bat バッチ

bld_????.bat は実際には bld1_????.bat を呼び出している。

bld1_????.bat は各ライブラリのフォルダに掘り込んで、基本的にそれのみで実際にビルドを行えるようにしてある。
(一部tiny_replstr.exeや追加バッチが必要なものあり)
x86(Win32) と x64 の切り替えはコンパイル環境の切り替えを伴うため、そのへんは bld_????.bat 側で行っている。


## 各ライブラリについて

もともとのビルド環境のmakefile等の引数指定で、コンパイラ・オプション変更して構築している。
単純に元の環境でビルドしたものとは(オプティマイズ等)違ったライブラリになっているので注意。

boost等ライブラリ側ビルドでディレクトリ分けがされてない限り、基本的に毎度フルビルドになる。

一応、試したライブラリのバージョンではビルドできているが、新しいバージョンや古いバージョンの
ライブラリでうまくいくかは不明（やってみなければわからない)

以下は、主にvc14.1でチェック. vc12は一通り通るが vc9は通らないこともあり、その場合は
vcの他のバージョンも試した。(ので言及してないVCバージョンでの成否は不明)


### ファイル数の少ないライブラリ(misc_inc,misc_lib 配置のもの)

bld_系バッチで共通で使われるバッチとして、libs_config.bat(変数設定), setcc.bat(vc切替バッチ) がある。
また tiny_replstr.exe が必要な場合、無ければコンパイルするために gen_tiny_replstr.bat が呼ばれる。


#### zlib
- データ(ファイル)圧縮関係
- bld_zlib.bat (+ bld1_zlib.bat +共通bat)
- ディレクトリは zlib*　- 試したバージョンは zlib-1.2.8, 2018-11-03付近のgitリポジトリ
- バッチ内では、win32/Makefile.vc の引数でCFLAGS等指定してコンパイルオプションを変えている。
- dllライブラリ版を使用する場合は、zlib.h のinclude前にZLIB_DLLを#defineしておく必要がある。
- libpng, tiff, boost, wxWidgets 等 各種ライブラリビルド時にソースなり .lib なりが参照される。
- vc8-14.1 のビルド通るはず


#### bzip2(libbz2)
- データ(ファイル)圧縮関係
- bld_bzip2.bat (+ bld1_bzip2.bat +共通bat)
- ディレクトリは bzip2* 　- 試したバージョンは bzip2-1.0.6, 2018-11-03付近のgitリポジトリ
- バッチ内では、makefile.msc の引数でOPTFLAGS等各種指定してビルド。
- boost ビルド時にソースincludeされる。
- vc8-14.1 のビルド通るはず


#### libpng
- png画像ファイル関係
- bld_libpng.bat (+ bld1_libpng.bat +共通bat)
- ディレクトリは lpng* 　- 試したバージョンは 1.6.35 / 2018-11-03付近のgitリポジトリ
- zlib 必須
- scripts/makefile.vcwin32 の引数でCFLAGS,CPPFLAGSを設定してビルド
- libharuビルド時に参照される
- vc8-14.1 のビルド通るはず


#### jpeg(libjpeg)
- jpeg画像ファイル関係
- bld_jpeg.bat (+ bld1_jpeg.bat +共通bat)
- ディレクトリは jpeg* 　- 試したバージョンは 最初:jpeg-9a  最新:jpeg-9b
- バッチ内では、makefile.vc の引数で、cflags等の各種設定を変えてビルド
- config.h がなければ config.vc をコピーして用意。不足してるwin32.makも生成
- tiffビルド時に参照
- vc8-14.1 のビルド通るはず


#### libjpeg-turbo
- jpeg画像ファイル関係. libjpegの派生
- bld_libjpeg-turbo.bat (+ bld1_libjpeg-turbo.bat +共通bat)
- ディレクトリは libjpeg-turbo* 　- 試したバージョンは 2016-02-13付近のgitリポジトリ  (最新は 2018-11-03付近)
(以前試した libjpeg-turbo-code-1537-trunk とはビルドスクリプト変わってたので 今のに合わせて修正済)
- turbo版はlibjpegの派生で、libjpeg,libjpeg-turbo, mozjpeg の混在は不可
- misc_inc を使う場合は、libjpeg,libjpeg-turbo,mozjpeg のいづれか一つのみ（最後のビルドのもの)が有効
- cmake, nasm 必須
- DLLランタイム版のビルドは用意されていないので、無理やりバッチ内で、flags.make や CMakeLists.txt を書き換えた別ファイルを生成してビルド
- vc8-14.1 のビルド通るはず

#### mozjpeg
- jpeg画像ファイル関係. libjpeg-turbo の派生
- bld_mozjpeg.bat (+ bld1_mozjpeg.bat +共通bat)
- ディレクトリは mozjpeg* 　- 初めて試したバージョンは 2017-03-19付近のgitリポジトリ (最新は 2018-11-03付近)
- libjpeg,libjpeg-turbo,mozjpegの混在リンクは不可
- misc_inc を使う場合は、libjpeg,libjpeg-turbo,mozjpeg のいづれか一つのみ（最後のビルドのもの)が有効
- cmake, nasm 必須
- DLLランタイム版のビルドは用意されていないので、無理やりバッチ内で、flags.make や CMakeLists.txt を書き換えた別ファイルを生成してビルド
- vc8-14.1 のビルド通るはず


#### libtiff
- tiff画像ファイル関係
- bld_libtiff.bat (+ bld1_libtiff.bat +共通bat)
- ディレクトリは libtiff* 　- 初めて試したバージョンは tiff-4.0.3 (最新は 2018-11-03付近のリポジトリ)
- zlib, libjpeg ほぼ必須. なくてもビルドできるが圧縮未対応になるので、予め zlib, libjpeg をビルド済のこと
- ライブラリビルド時は zlib, libjpeg として mic_inc&misc_lib のものを使用
- バッチ内では、Makefile.vc の引数で各種指定してビルド
- vc8-14.1 のビルド通るはず


#### libharu
- pdf関係
- bld_libharu.bat (+ bld1_libharu.bat +共通bat)
- ディレクトリは libharu* 　- 試したバージョンは libharu-RELEASE_2_3_0 (あるいは 2018-11-03付近でのリポジトリ)
- zlib, libpng ほぼ必須。 予め ビルド済みのこと。 (無でビルドする方法はある模様)
- ライブラリビルド時は zlib, libpng として mic_inc&misc_lib のものを使用
- 無精して dll ライブラリ版は未生成。(ファイル名の都合もあり)
- demo をコンパイルすると jpfont_demo.exe の実行でエラー。jpfont_demo.c 中のフォント名 MS-Mincyo が原因。 全てMS-Minchoに置換すればok
- なので libharu をビルドする場合は予め 修正しておくこと
- png_demo は生成されたpdfを開くとエラー発生("画像データに不足があります"で実際途中から表示無く)。 (libpngのバージョン違い?)
- バッチ内では、script/makefile.msvc の引数で CFLAGS,LDFLAGS等の各種設定を変えてビルド
- 上記ソース修正した状態で vc8-14.1 のビルド通るはず


#### glfw
- OpenGL フレームワーク.
- bld_glfw.bat (+ bld1_glfw.bat +共通bat)
- ディレクトリは glfw* 　- 試したバージョンは 最初:glfw-3.1.1  最新: 2018-11-03付近でのリポジトリ
-- glfw-?.?.?/lib/ の下に vc??_x??[_static][_debug]  のようなディレクトリを作りその下に.libを配置
- バッチ内では、CMake の引数で所定の変数を設定してビルド
- depth/libmath.h が c99,c++ では通るがc89では通らない書き方で、testプログラムの類が.cで vc11以前では
エラーになるため、これらはライブラリのみのビルドを行う。vc12以降はc99機能対応有なのでtestも含めてビルドする
- 上記状態で vc8-14.1 のビルド通るはず


#### libogg
- oggファイル関係の肝 (libvorbis等で使われる)
- bld_libogg.bat (+ bld1_libogg.bat, tiny_replstr.exe +共通bat)
- ディレクトリは libvogg-?.?.? 　- 試したバージョンは libogg-1.3.2
- ライブラリ側での.lib生成場所は、元の win32/vs20??環境のまま. win32/VS20??/Win32/ か win32/VS20??/x64/ の下に Debug/ Release/ がある状態
- libogg_static.sln はdllランタイム前提だったので、_static.vcxproj 等を
  バッチ内で書き換えて staticランタイム版をビルド、逆にdllランタイム版の名前を _rtdll 付きに変えている
- dllランタイム版 _rtdll は misc_lib/ へのコピー時に 他のライブラリとネイミングを合わせるため _static に付け直している
- (_static版のランタイム指定が liboggとlibvorbisで違うような... dll(_dynamic)ライブラリ版しか使ってないの？)
- msbuildで libogg_static.sln, libogg_dynamic.sln に所定の引数与えてビルド 
- vc12,vc14,vc14.1 はビルド通ったが、vc8-11は全くダメだったり一部ダメだったりと不具合有(原因未調査)


#### libvorbis
- 音声圧縮関係
- bld_libvorbis.bat (+ bld1_libvorbis.bat, tiny_replstr.exe +共通bat)
- ディレクトリは libvorbis-?.?.? 　- 試したバージョンは libvorbis-1.3.5
- libogg を使う
- バッチ内では、用意された vc sln 環境を使うが、vs2012(vc11),vs2013(vc12)用は vs2010(vc10)環境から生成している
- ライブラリ側での.lib生成場所は、元の win32/vs20??環境のまま。
  win32/VS20??/Win32/ か win32/VS20??/x64/ の下に Debug/ Release/ がある状態
- *_static.sln はdllランタイム前提だったので、_static.vcxproj 等をバッチ内で書き換えて
  staticランタイム版をビルド、逆にdllランタイム版の名前を _rtdll 付きに変えている
- dllランタイム版 _rtdll は misc_lib/ へのコピー時に 他のライブラリと
  ネイミングを合わせるため _rtdll無にし、無のほうを _static に付け直している
- vc11以前では何がしかビルド失敗(vc9以前はmsbuildがハング)。
  新し目のmsbuildを流用するとハングはしないがエラー有)
- vc12,vc14,vc14.1 はビルド通ったが、vc8-11は全くダメだったり一部ダメだったりと不具合有(原因未調査)


#### openssl (libssl, libcrypto)
- ssl関係
- bld_openssl.bat (+ bld1_openssl.bat, tiny_replstr.exe +共通bat)
- ディレクトリは openssl-?.?.? 　試したバージョンは openssl-1.1.0f
- perl必須. libs_config.bat に perlのpathを設定のこと。
- ライブラリの生成のみ。実行ファイルは無視。(生成するけどすぐ削除)
- dll ライブラリ版は未生成。※直にbld1_openssl.batでdll指定すればdll版生成可能。
- misc_inc/ へは、バイパスヘッダでなく include/openssl/ フォルダのヘッダをそのままコピー。
- perlで生成されたmakefileが/Mt版のみのため /Md用はテキスト置換して用意.
- debug版の生成無し。debug版ディレクトリには release版をコピー。
- vc8-14.1 のビルド通るはず


### pixman
- 画像関係
- bld_pixman.bat (+bld1_pixman.bat, tiny_replstr.exe+共通bat)
- ディレクトリは pixman* 試したバージョンは 2018-11-03付近のgitリポジトリ
- mingw32-make.exe (mozmake.exe) が必要.
-- libs_config.bat の CcWinGnuMake に exeファイルを指定
- ライブラリのみ. テスト等は手付かず.
- vc2017 で Cinder の blocks/cairo を使えるようにするためにビルド. 
- 少なくとも vc14-14.1 のビルド通るはず


### cairo
- 画像関係
- bld_cairo.bat (+bld1_cairo.bat, sub/cairo の makefile郡+共通bat)
- ディレクトリは cairo* 試したバージョンは ver.1.16 の gitリポジトリ
- mingw(32)の msys1 環境(あるいは mozila-build/) が必要.
-- libs_config.bat の CcMsys1Paths に ～/msys/local/bin;～/msys/bin にパスを通す
- ライブラリのみ. テスト等は手付かず.
- vc2017 で Cinder の blocks/cairo を使えるようにするためにビルド. 
- 少なくとも vc14-14.1 のビルド通るはず



### 大きめのライブラリ(misc_*/に置かない)

#### boost
- 巨大汎用ライブラリ
- bld_boost.bat (+ bld1_boost.bat +共通bat)
- ディレクトリは boost_?_??_? 　- 試したバージョンは 最初:boost_1_57_0 最新:boost_1_60_0
- でっかいし環境整ってるので、boostの環境のまま使用
- libs_vc??/直下に zlib*, bzip2* のフォルダを予め用意してあれば、それらを使ってライブラリ構築する
- ※ boost環境内でzlib,libbz2を含んだライブラリが作られるので、予めzlibやlibbz2を構築する必要はない
- gilで使う jpeg、png、tiffについては、使う側で、jpeglib.h,png.h,tiff.h が
  そのままincludeできlibがリンクされるようにする必要がある
(gil自体は ヘッダオンリーのライブラリのようで、boost構築時にjpeg,png,tiffについて何かする必要はない)
- .lib は boost-?????/stage/vc??_(Win32|x64)[_static](_release|_debug)/ ディレクトリに生成される
- vc8,9,12,14,vc14.1 のビルド通した(他は未確認)


#### OpenCV
- 画像処理ライブラリ
- bld_opencv.bat (+bld1_opencv.bat +共通bat)
- ディレクトリは opencv-?.?.? 　- 試したバージョンは opencv-3.1.0.zip, 最新の試しは3.4
- .lib は opencv-?.?.?/lib/vc??_(Win32|x64)[_static](_release|_debug)/ ディレクトリに生成
- _static付がstaticランタイム版。無しがdllランタイム版。
- dll(shared)版の生成は行っていない。(直に bld1_opencv.bat で dll 指定すれば可能)
- デバッグ版のライブラリはファイル名の最後に 'd' がつく。
- ビルドは build/vc??_(Win32|x64)[_static](_release|_debug)/ ディレクトリを作ってそこで行っている。
  終了しても残っているので、不要なら削除のこと。
- バッチ内では、CMake の引数で所定の変数を設定してビルド
- v3.1.0は vc10exp,vc12,14 でビルド通った。vc11はCMake中にエラー。  
  vc9以下は公式未対応の模様。stdint.h必須だし。ただ代用stdint.h用意してOpenCL オフにすればvideoio関係
  以外はコンパイル通るかも。あとvc8,vc9はIDE上ではビルドを試せたがmsbuild.exeはハングして駄目だった。
- v3.4は vc14,vc14.1 で試し. 現状中途半端
-- フォルダ構成を変更. opencv/sources に opencv.git の内容を置き、opencv/build でビルド、
opencv/build/vc???_(x64|Win32)(_static)/install が、実際に使うフォルダになる。
-- pythonをインストールしてると opencv_python がビルドされるが、 python側の Python.h で python??_d.lib
のリンクが設定されてしまうが、実物なくリンクエラー(opencv側は python??.libを使うようにしてる模様).
とりあえず opencv_python をビルドしないことで回避.

#### wxWidgets v3
- GUIフレームワーク
- bld_wxWidgets.bat (+ bld1_wxWidgets.bat + UpgradeWxWidgetsSampleVcproj.bat +共通bat)
- ディレクトリは wxWidgets-3.?.? 　- 試したバージョンは 最初:wxWidgets-3.0.2  最新:wxWidgets-3.1.0
- でっかいし環境整ってるので、wxWidgetsの環境のまま使用
- ただし生成されたライブラリは lib/ ディレクトリ直下にwx標準とは違う  
    vc??(_x64)_rtdll_lib/   　　　　dllランタイム版  
    vc??(_x64)_static_lib/  　　　　staticランタイム版  
    vc??(_x64)_dll/         　　　　dllライブラリ版  
  のようなディレクトリに配置。  
  が実際に使うときは wxWidgets 内部での include の都合もあり、vc??_rtdll_lib か vc??_static_lib かどちらかを
  vc_lib (x64版なら vc_x64_lib) に rename する必要がある。（dll版の場合は vc_dll）  
  (ただコンパイラオプションで wxMSVC_VERSION_AUTO マクロを定義した場合は、vc120_lib のようにvcバージョンが
  ついたディレクトリが対象になるので、都合に合わせてrenameすることになる)
- debug版ライブラリは、release版のファイル名の最後に 'd' を付加した名前になっている
- v3.1.0では直っているようだが、vc14(vs2015)で wxWidgets v3.0.2 のソースを
  コンパイルすると tif_config.h の #define sprintf _sprintf が、
  vc14の stdio.h でのマクロ対策#errorのせいでエラーになる  
  なのでvc14でコンパイルする場合は src/tiff/libtiff/tif_config.h の 367 行目付近の  
    #define snprintf _snprintf  
  の行を  
    #if !defined(_MSC_VER) || _MSC_VER < 1900  
    #define snprintf _snprintf  
    #endif  
  のように書き換える必要がある。
- バッチ内では makefile.vc に所定の引数渡してビルド
- vc9,12,14 はビルド通った。 他vcについては未確認


#### fltk
- GUIフレームワーク
- bld_fltk.bat (+ bld1_fltk.bat + UpgradeFltkIdeVcproj.bat + tiny_replstr.exe +共通bat)
- ディレクトリは fltk-?.?.? 　- 試したバージョンは fltk-1.3.3
- でっかいので、fltkの環境のまま使用
- zlibやpngライブラリを使っているが、ソースは予め配布ライブラリ内に含まれている
- デバッグ用ライブラリについては、元のまま 最後に d がついたモノを使うことになる
- .lib は lib/ の下の  
    vc??_Win32/  
    vc??_Win32_static/  
    vc??_x64/  
    vc??_x64_static/  
  に作られる。
- _static付がstaticランタイム版で デバッグ版に関してはディレクトリ別でなくファイル名の最後に 'd' がつく。
- バッチ内では、dllランタイム版は、msbuild fltk.sln で Configuration, Platform を指定してビルド
- static ランタイム版やx64版は用意されていないので .slnや.vcxprojを無理やり書き換えたものを生成してビルド
- vc10exp,vc12,vc14はビルド通った。vc8,9,11は失敗(原因未調査)


#### Cinder
- マルチメディア・フレームワーク
- samples や test の対応等していろいろ単純でなくなったので本家からforkした
  https://github.com/tenk-a/Cinder  
  に for_vc2017 ブランチで対応.



## 履歴
- 2018-11-03 misc_inc/のヘッダをラッパーでなくヘッダ実体をコピーするように変更。  
このためラッパーヘッダによる暗黙のリンクがなくなったので、.libはそのつどリンク指定する必要あり.  
bld1_???.bat では libs_config.bat のCc????変数を直接みないようにして なるべくbld1_???単体利用可能にした.  
現状 vc14.1でコンパイルしてみただけ、で実使用してないので不具合多そう
