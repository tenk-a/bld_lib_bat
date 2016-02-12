## 各種opensourceライブラリを vc でビルドするためのバッチ

vc 対応の opensource ライブラリのいくつかを まとめてビルドするためのバッチ群。

配布元のlibバイナリや、ライブラリのデフォルトの設定でコンパイルした場合
Cランタイム(crt) が static か dll使用(msvcrt*.dll) かマチマチだったり、
また(c++ の場合) 異なるバージョンの vc++ でコンパイルしたライブラリの
リンクが弾かれることがあったりと配布ままのバイナリが使えないことがあるので
ソースをビルドするはめになるのだが細々面倒なもので...

boost のように ランタイムのstatic/dll, ライブラリ自身のstatic/dll 対応
別にファイル名を変えてくれるものもあるが、debug/releaseの区別なくソース
フォルダに１つ(1式)生成するだけのものも多いので、そういうビルド＆フォルダ
仕訳を多少楽にするために作業バッチ化.


## コンパイルするライブラリ

大きいライブラリ
- 現状 boost, wxWidgets, fltk  
これらは、それらの標準のincludeやlibのパスを使う.

比較的小さいライブラリ
- 現状 zlib, libbz2, libpng, jpeglib, libjpeg-turbo, libtiff, libharu, glfw3, libogg, libvorbis  
これらは misc_inc/ , misc_lib/ ディレクトリにまとめる.


## 方針

- 展開したライブラリ・ソース中のファイルを編集しない。
が、ライブラリの出力先等、そのフォルダ内にファイルの追加は有.
また、Makefileに対し引数でオプション設定変更したりは当然する.

- 一応バッチのライセンスは boost software license version 1.0 という
ことにしとく(当然 各ライブラリのライセンスはそれぞれ)

- vcのバージョンは１種類のみを前提. 別のバージョン用をビルド
する場合は 別ディレクトリで同様に用意.
※ フォルダ名に vcバージョンを含めると、利用側でのコンパイラ名対応
がちょっと面倒、と、いう考え.

- ライブラリを貯めるディレクトリを用意し、そこに各種ライブラリを
展開しておき、バッチでビルド。生成されたライブラリは、基本的には
ソース環境のまま利用可能(ヘッダ・ファイルをそのまま使う).
-- ただし生成されたライブラリの配置は、debug|release, static|dllランタイム,
ターゲットライブラリ自身のstatc|dll, の都合でフォルダ分けし直している.
(一種類の生成しか想定していないライブラリも多い)


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
        set CcName=vc8～vc12                         　　使用するvcコンパイラ.  
        set CcHasX64=0 or 1                          　　x86のみなら 0, x64版もビルドするなら 1  
        set CcNoRtStatic=0 or 1                      　　staticランタイム版を生成しない場合 1を設定(vc++Expressでは必須)  
        set CcCMakeDir=%ProgramFiles(x86)%\CMake\bin 　　libjpeg-turbo や glfw 等cmakeを使う場合, cmakeのディレクトリを設定.  
        set CcNasmDir=c:\tools\nasm                  　　 libjpeg-turbo 等 nasm を使う場合、nasmのディレクトリを設定.  
  を自身の環境に合わせて書き換える.  
  ※ その他 Cc???? はバッチ共通で使うデフォルト値  


- ビルドしたいライブラリを入手(ダンロード)して d:\libs_vc\ の直下に解凍.  
  フォルダ名はバージョン番号等含んだデフォルトのままのこと.  
  たとえば zlib だと zlib128.zip を入手＆解凍、  
    d:\libs_vc\zlib-1.2.8  
  が出来る.  
  d:\libs_vc\bld_lib_bat\ をカレント・ディレクトリにして  
    bld_zlib.bat  
  を実行.  
    d:\libs_vc\misc_inc\  
  にヘッダ zlib.h が生成され
  (作られた zlib.h は zlib-1.2.8 にある本物のzlib.h をincludeするだけのラッパー)  
    d:\libs_vc\misc_lib\vc_x86  
    d:\libs_vc\misc_lib\vc_x86_debug  
    d:\libs_vc\misc_lib\vc_x86_static  
    d:\libs_vc\misc_lib\vc_x86_static_debug  
  等に zlib.lib が生成される.  
  ※ ターゲットディレクトリ名はzlib*のように指定して、名前ソートで最後に見つかった
     モノを使うが、わかりにくいので複数のバージョンを置くのは避けたほうがよいだろう。


## misc_inc

misc_inc/ には、ライブラリ別にディレクトリを用意、その中にヘッダを入れている.
置かれるヘッダは 本来のヘッダをincludeするラッパーとなる.(実態のコピーはしない)

比較的小さめのライブラリ群のヘッダを集めたディレクトリだが、プログラム組む上では
本来のライブラリ側のディレクトリからincludeしたほうが無難かもしれない。
（ただ複数のライブラリを使うなら統一的に扱えるのでmisc_incもありかと）


## misc_lib や 生成するライブラリについて

boostやwxWidgetsのように仕分け対応積みのモノもあるが、debug|release、static|dll 等の
設定違い別にディレクトリを変えたり名前を変えたりしていないライブラリも多々あるため、
仕分け対応していないライブラリについては、このバッチ群独自にディレクトリ分けしている。

libs_vc/misc_lib/ に入るものについては、
- vc_x86
- vc_x86_debug
- vc_x86_static
- vc_x86_static_debug
- vc_x64
- vc_x64_debug
- vc_x64_static
- vc_x64_static_debug

のようになる。misc_lib/ の下に作られるディレクトリもそうだし、各ライブラリでのビルドでも
そのディレクトリ下のlib/ ディレクトリに上記のようなディレクトリを作り、その中に*.libを置く.

ディレクトリ名は、世間一般？にvc++express版のこともあってかdllランタイム版が基本のようなので、それらに倣い、
_debugがあればdebugビルド(なければrelease)、_staticがあればstaticランタイム(なければdllランタイム:msvcrt???.dllを使う)とした。

生成される各ライブラリのファイル名は、なるべく元のビルドのままにしたかったが、debugビルドやランタイムの区別のため、
元とは違うポストフィックス(_debugや_static)をつけている場合もある。 実際に生成されたファイル名を確認のこと.

ターゲットライブラリ自身のdll版は、ビルドに用意されていれば一応ビルドしている。(が用意されていないターゲットも多いので...)

dllライブラリ版は用意されている場合は、staticライブラリ版を別名で生成しているだろう。
dllライブラリ版がある場合のstatic版は、元々ライブラリ名に _static や -static が後ろについていることもあり、そうでないものもそれに倣った。

※紛らわしいが、ディレクトリ名のstatic はランタイムを表し、ライブラリファイル名に付くstaticはターゲットライブラリがstaticリンクであることを表している。

※ 私自身は、staticランタイム＆staticターゲットライブラリが主目的なので、他はおざなりかもしれない。



## makefileやvcxproj等に対する文字列置換

ものによっては、makefile や sln,vcxproj ファイルの特定の文字列を置換したファイルを生成する必要があり、
cmd.exeの置換機能では対処しきれないケースもあったため、簡易なテキスト置換ツール
  tiny_replstr(.cpp)
を バッチ実行時に(未生成なら)コンパイルして使用している。


## bld1_????.bat バッチ

bld_????.bat は実際には bld1_????.bat を呼び出している.
bld1_????.bat は各ライブラリのフォルダで それのみ で実際にビルドを行うためのバッチで、一応、それだけでも使えるようにしたつもり。
x86 と x64 の切り替えはコンパイル環境の切り替えを伴うため、そのへんは bld_????.bat 側で行っている。


## 各ライブラリについて

もともとのビルド環境のmakefile等の引数指定で、コンパイラ・オプション変更して構築している。
単純に元の環境でビルドしたものとは(オプティマイズ等)違ったライブラリになっているので注意。

### misc_inc,misc_lib 配置のもの

#### zlib
- データ(ファイル)圧縮関係
- bld_zlib.bat
- ディレクトリは zlib-?.?.?
- 試したバージョンは zlib-1.2.8
- バッチ内では、win32/Makefile.vc の引数でCFLAGS等指定してコンパイルオプションを変えている.
- dllライブラリ版を使用する場合は、zlib.h のinclude前にZLIB_DLLを#defineしておく必要がある.
- libpng, boost, wxWidgets, openFramework 等 各種ライブラリから ソースなり .lib なりが参照される.


#### bzip2(libbz2)
- データ(ファイル)圧縮関係
- bld_bzip2.bat
- ディレクトリは bzip2-?.?.? 　- 試したバージョンは bzip2-1.0.6
- バッチ内では、makefile.msc の引数でOPTFLAGS等各種指定してビルド.
- boost からソースincludeされる.


#### lpng(libpng)
- png画像ファイル関係
- bld_lpng.bat
- ディレクトリは lpng???? 　- 試したバージョンは lpng1616
- zlib 必須
- scripts/makefile.vcwin32 の引数でCFLAGS,CPPFLAGSを設定してビルド.


#### jpeg(libjpeg)
- jpeg画像ファイル関係
- bld_jpeg.bat
- ディレクトリは jpeg-?? 　- 試したバージョンは jpeg-9a
- バッチ内では、makefile.vc の引数で、cflags等の各種設定を変えてビルド。


#### libjpeg-turbo
- jpeg画像ファイル関係. libjpegの派生
- bld_libjpeg-turbo.bat
- ディレクトリは libjpeg-turbo-* 　- 試したバージョンは libjpeg-turbo-code-1537-trunk
- turbo版はlibjpegの派生で、libjpeg,libjpeg-turboの混在リンクは不可.
- cmake, nasm 必須
- DLLランタイム版のビルドは用意されていないので、無理やりバッチ内で、flags.make や CMakeLists.txt を書き換えた別ファイルを生成してビルド.


#### tiff(libtiff)
- tiff画像ファイル関係
- bld_tiff.bat
- ディレクトリは tiff-?.?.? 　- 試したバージョンは tiff-4.0.3
- zlib, libjeg 利用. なくてもビルドできるが圧縮未対応になるので、予め zlib, libjpeg をビルド済のこと.
- バッチ内では、Makefile.vc の引数で各種指定してビルド.


#### libharu
- pdf関係
- bld_libharu.bat
- ディレクトリは libharu-* 　- 試したバージョンは libharu-RELEASE_2_3_0
- zlib, lpng 必須. 予め ビルド済みのこと.
- demo をコンパイルすると jpfont_demo.exe の実行でエラー。jpfont_demo.c 中のフォント名 MS-Mincyo が原因. 全てMS-Minchoに置換すればok.
- なので libharu をビルドする場合は予め 修正しておくこと。
- バッチ内では、script/makefile.msvc の引数で CFLAGS,LDFLAGS等の各種設定を変えてビルド。


#### glfw
- OpenGL 関係
- bld_glfw.bat
- ディレクトリは glfw-3.?.? 　- 試したバージョンは glfw-3.1.1
- バッチ内では、CMake の引数で所定の変数を設定してビルド.
-- glfw-?.?.?/lib/ の下に vc??_x??[_static][_debug]  のようなディレクトリを作りその下に.libを配置.


#### libvorbis
- 音声圧縮関係 (oggで使われる)
- bld_libvorbis.bat
- ディレクトリは libvorbis-?.?.? 　- 試したバージョンは libvorbis-1.3.5
- libogg で使う
- バッチ内では、用意された vc sln 環境を使うが、vs2012(vc11),vs2013(vc12)用は vs2010(vc10)環境から生成している.
-- *_static.sln はdllランタイム前提だったので、_static.vcxproj 等をバッチ内で書き換えてstaticランタイム版をビルド.
-- (ビルド環境内では dllランタイム版は _rtdll をつけて生成し、misc_libへのコピー時に_staticに付け直している).
-- tiny_replstr 使用


#### libogg
- ogg関係
- bld_libogg.bat
- ディレクトリは libvogg-?.?.? 　- 試したバージョンは libogg-1.3.2
- libvorbis 必須. ※ _static版のランタイム指定が liboggとlibvorbisで違うような... dll(_dynamic)ライブラリ版しか使ってないの？
- msbuildで libogg_static.sln, libogg_dynamic.sln に所定の引数与えてビルド. 
-- バッチ内では、dllランタイム用が無いのでバッチ内でlibogg_static.slnからdllランタイム用slnを生成してビルド.
-- 最終的にmisc_lib/へコピーされるが、ビルド中のライブラリ生成ディレクトリは元とは多少違う.
-- (ビルド環境内では dllランタイム版は _rtdll をつけて生成し、misc_libへのコピー時に_staticに付け直している).
-- tiny_replstr 使用


### misc*系に置かないモノ

#### boost
- 巨大汎用ライブラリ
- bld_boost.bat
- ディレクトリは boost_?_??_? 　- 試したバージョンは boost_1_58_0
- でっかいし環境整ってるので、boostの環境のまま使用。
- vc_libs/直下に zlib*, bzip2* のフォルダを予め用意してあれば、それらを使ってライブラリ構築する.
- ※ boost環境内でzlib,libbz2を含んだライブラリが作られるので、予めzlibやlibbz2を構築する必要はない.
- ※jpegやpngについては現状未対応
- .lib は libs_vc/boost/stage/vc??_x??[_debug][_static]/ に生成される


#### wxWidgets v3
- GUIフレームワーク
- bld_wxWidgets.bat
- ディレクトリは wxWidgets-3.?.? 　- 試したバージョンは wxWidgets-3.0.2
- でっかいし環境整ってるので、wxWidgetsの環境のまま使用。
- makefile.vc に所定の引数渡してビルド.


#### fltk
- GUIフレームワーク
- bld_fltk.bat
- ディレクトリは fltk-?.?.? 　- 試したバージョンは fltk-1.3.3
- でっかいので、fltkの環境のまま使用。
- zlibやpngライブラリを使っているが、ソースは予め配布ライブラリ内に含まれている.
- デバッグ用ライブラリについては、元のまま 最後に d がついたモノを使うことになる.
- .lib は lib/ の下に、misc_lib 同様のサブディレクトリを掘ってそこに入れている.
- バッチ内では、dllランタイム版は、msbuild fltk.sln で Configuration, Platform を指定してビルド.
-- static ランタイム版やx64版は用意されていないので、.slnや.vcxprojを無理やり書き換えたものを生成してビルド.
-- tiny_replstr 使用

