% Pandocユーザーズガイド 日本語版
% John MacFarlane
% Japanese Translation: Yuki Fujiwara
% January 19, 2013

書式
====

pandoc [*options*] [*input-file*]...

説明
====

Pandocは [Haskell] で書かれたライブラリおよびコマンドラインツールであり、
あるマークアップ形式で書かれた文書を別の形式へ変換するものです。

対応している入力形式は以下の通りです： [markdown]、[Textile] （のサブセット、以下同様）、
[reStructuredText]、 [HTML]、[LaTeX]、[MediaWiki markup]、[Haddock markup]、[OPML]、[DocBook]。

出力形式は以下の通りです：プレーンテキスト、[markdown]、[reStructuredText]、[XHTML]、[HTML 5]、
[LaTeX] （[beamer]スライドショーを含む）、[ConTeXt]、[RTF]、[OPML]、[DocBook]、
[OpenDocument]、[ODT]、[Word docx]、[GNU Texinfo]、[MediaWiki markup]、
[EPUB] (v2またはv3)、[FictionBook2]、[Textile]、[groff man]ページ、 [Emacs Org-Mode]、[AsciiDoc]、
およびスライドショーの形式である[Slidy]、[Slideous]、[DZSlides]、[reveal.js]、[S5] HTMLスライドショー。

Pandocによる拡張Markdown書式は以下を含みます：脚注、表、柔軟な順序付きリスト、
定義リスト、囲う形式のコードブロック、上付き文字、下付き文字、取り消し線、
タイトルブロック、目次の自動作成、LaTeX数式の埋め込み、引用、HTMLブロック要素のMarkdownへの埋め込み。
（これらの拡張については、以下の [Pandocによる拡張Markdown](#pandocs-markdown) にて説明されます。
また、これらの拡張は入力および出力形式として`markdown_strict`を与えることで無効にできます。）

正規表現による置換を使ってHTMLからMarkdownに変換する多くのツールに対して、
Pandocはモジュール式のデザインで構成されています。
Pandocは、与えられた形式のテキストを解析してHaskell Native形式に変換するReader、
およびHaskell Native形式をターゲットの出力形式に変換するWriterで構成されており、
これらは各々の入力・出力形式ごとに存在します。
つまり、入力または出力形式を追加するには、ReaderまたはWriterを追加するだけでよいのです。

`pandoc` の使い方
----------------

入力ファイルとして*input-file*が指定されていない場合は、
入力として標準入力 *stdin* が指定されます。
*input-file*が指定されている場合は、それが入力として指定されます。
（ファイルを複数とることも可能です。）

出力ファイルはデフォルトで標準出力 *stdout* に出力されます。
（ただし出力フォーマットが`odt`、`docx`、`epub`、`epub3`の場合は、
標準出力への出力が無効となります。）
ファイルへ出力したい場合は、`-o`オプションを使用してください：

    pandoc -o output.html input.txt

ファイルの代わりに、絶対パスのURIを指定することもできます。
この場合、PandocはHTTPを用いてコンテンツを取得します。

    pandoc -f html -t markdown http://www.fsf.org

複数の*input-file*が指定されている場合、Pandocは解析の前に、
各入力ファイルを結合してその間に空行を挿入します。

入力および出力フォーマットはオプションを用いて明示的に指定できます。
入力フォーマットは`-r/--read`または`-f/--from`により、
出力フォーマットは`-w/--write`または`-t/--to`により指定できます。
例えば、LaTeXファイルの`hello.txt`を入力とし、Markdownに出力する場合は、
以下のようなコマンドを作れるでしょう：

    pandoc -f markdown -t latex hello.txt

HTMLファイルの`hello.html`をMarkdownに変換する場合はこうです：

    pandoc -f html -t markdown hello.html

サポートされている出力フォーマットについては、後の`-t/--to`オプションの項で、
入力フォーマットについては、`-f/--from`オプションの項でリストアップします。
注意：`rst`、`textile`、`latex`、`html`のReaderはそれぞれのフォーマットを
完全にサポートしません。これらの文書の要素には、無視されるものがあります。

入力または出力フォーマットが明示されていない場合、
Pandocはファイル名の拡張子から入力・出力フォーマットを推測しようとします。
例えば、このように、

    pandoc -o hello.tex hello.txt

は`hello.txt`をMarkdownからLaTeX形式に変換します。

出力ファイルが指定されていない場合（この場合標準出力に出力されます）、
または出力ファイルの拡張子が不明な場合は、`-t/--to`オプションで明示しない限り、
出力フォーマットはデフォルトとしてHTMLが選ばれます。
入力ファイルが指定されていない場合（この場合は入力を標準入力から得ます）、
または入力ファイルの拡張子が不明な場合は、`-f/--from`オプションで明示しない限り、
入力フォーマットはMarkdownとして扱います。

Pandocは入力・出力のデフォルトエンコーディングとしてUTF-8を採用しています。
UTF-8以外の文字コードを利用したい場合は、`iconv`などの文字コード変換ツールにより
入力や出力をパイプする必要があります：

    iconv -t utf-8 input.txt | pandoc | iconv -f utf-8

PDFを作成する [creating-a-pdf]
------------

初期のPandocは、PDF生成のためにPandocとpdfLaTeXを用いる `markdown2pdf` というプログラムとともに発展しました。
現在はPandoc自身がPDFを生成できるため、このプログラムは必要ありません。

PDFを生成するには、単に出力ファイルの拡張子として `.pdf` を指定するだけです。
Pandocは内部でLaTeXファイルを作成し、それをpdfLaTeXを用いてPDFに変換します。
（他のLaTeXエンジンを利用するには、`--latex-engine`の項をご覧ください。）

    pandoc test.txt -o test.pdf

（訳注：pdfLaTeXは日本語に対応していません。その代わりに、LuaLaTeXの利用を推奨します。
インストールやコマンドなどの詳細は以下のページをご覧ください。
[HTML - 多様なフォーマットに対応！ドキュメント変換ツールPandocを知ろう - Qiita](http://qiita.com/sky_y/items/80bcd0f353ef5b8980ee) ）

PDFの生成のためには、LaTeXエンジンがインストールされている必要があります
（詳細は以下の `--latex-engine` の項をご覧ください）。
以下のLaTeXパッケージは有効であると見なされます：
`amssymb`, `amsmath`, `ifxetex`, `ifluatex`, `listings` (`--listings`オプションが有効の場合),
`fancyvrb`, `longtable`, `booktabs`, `url`, `graphicx`, `hyperref`, `ulem`,
`babel` (`lang`オプションが有効の場合),
`fontspec` (LaTeXエンジンとして`xelatex`または`lualatex`が指定されている場合),
`xltxtra` and `xunicode` (LaTeXエンジンとして`xelatex`が指定されている場合).

`hsmarkdown`
------------

`Markdown.pl`の暫定的な置き換えとしてPandocを利用したいユーザは、
`pandoc`実行ファイルへのシンボリックリンクを`hsmarkdown`として利用することができます。
Pandocを`hsmarkdown`として呼びだした場合、
Pandocはオプション `-f markdown_strict --email-obfuscation=references` が指定されたものとして呼びだされ、
全てのコマンドラインオプションは通常の引数として取り扱われます。
ただし、Cygwinの下ではシンボリックリンクのシミュレーションの問題により、この方法では動作しません。

[Cygwin]:  http://www.cygwin.com/
[`iconv`]: http://www.gnu.org/software/libiconv/
[CTAN]: http://www.ctan.org "Comprehensive TeX Archive Network"
[TeX Live]: http://www.tug.org/texlive/
[MacTeX]:   http://www.tug.org/mactex/


オプション
========

一般的なオプション [general-options]
----------------

`-f` *FORMAT*, `-r` *FORMAT*, `--from=`*FORMAT*, `--read=`*FORMAT*
:	入力フォーマットを指定します。*FORMAT* として指定できるのは以下のフォーマットです：
	`native` (Native Haskell; Haskellで読み込める形式のデータ構造),
	`json` (ネイティブASTのJSONバージョン),
	`markdown` (Pandocによる拡張Markdown), `markdown_strict` (オリジナルの拡張されていないMarkdown),
    `markdown_phpextra` (PHP Markdown Extraによる拡張Markdown),
    `markdown_github` (GitHubによる拡張Markdown),
    `textile` (Textile), `rst` (reStructuredText), `html` (HTML),
    `docbook` (DocBook), `opml` (OPML), `mediawiki` (MediaWikiマークアップ),
    `haddock` (Haddockマークアップ), `latex` (LaTeX)。
	`+lhs` をフォーマット `markdown`, `rst`, `latex`, `html` の後ろにつけ加えた場合、
	その入力はLiterate Haskellのソースコードとして扱われます
	（詳細は下記の[Literate Haskellのサポート](#literate-haskell-support)を参照）。
	Markdownの拡張文法は、フォーマットの末尾に`+EXTENSION`または`-EXTENSION`をつけ加えることで
	それぞれ有効・無効を切り替えられます。
	例えば、`markdown_strict+footnotes+definition_lists`は、
	`markdown_strict`をベースにして脚注と定義リストを有効にしたもの、という意味になります。
	同様に、`markdown-pipe_tables+hard_line_breaks`は、
	PandocのMarkdownからパイプテーブルを無効にし強制改行を有効にしたもの、という意味です。
	拡張とその名前の詳細については、下記の[Pandocによる拡張Markdown](#pandocs-markdown)をご覧ください。


`-t` *FORMAT*, `-w` *FORMAT*, `--to=`*FORMAT*, `--write=`*FORMAT*
:	出力フォーマットを指定します。*FORMAT*として指定できるのは以下のフォーマットです：
	`native` (Native Haskell), `json` (ネイティブASTのJSONバージョン),
	`plain` (プレーンテキスト), `markdown` (Pandocによる拡張Markdown),
	`markdown_strict` (オリジナルの拡張されていないMarkdown),
	`markdown_phpextra` (PHP Markdown Extraによる拡張Markdown),
	`markdown_github` (GitHubによる拡張Markdown),
    `rst` (reStructuredText), `html` (XHTML 1), `html5` (HTML 5),
    `latex` (LaTeX), `beamer` (LaTeX beamer スライドショー),
    `context` (ConTeXt), `man` (groff man), `mediawiki` (MediaWiki マークアップ),
    `textile` (Textile), `org` (Emacs Org-Mode), `texinfo` (GNU Texinfo),
    `opml` (OPML), `docbook` (DocBook), `opendocument` (OpenDocument), `odt`
    (OpenOffice/LibreOffice Writerドキュメント), `docx` (Word docx),
    `rtf` (リッチテキストフォーマット), `epub` (EPUB v2 book), `epub3`
    (EPUB v3), `fb2` (FictionBook2 e-book), `asciidoc` (AsciiDoc), `slidy`
    (Slidy HTML and javascript スライドショー), `slideous` (Slideous HTML and
    javascript スライドショー), `dzslides` (DZSlides HTML5 + javascript スライドショー),
	`revealjs` (reveal.js HTML5 + javascript スライドショー),
	`s5` (S5 HTML and javascript スライドショー),
	または カスタム Lua Writer へのパス(詳細は下記の [カスタムWriter](#custom-writers) を参照)。
	注意：`odt`, `epub`, `epub3`の出力は 標準出力 *stdout* に出力されないため、
	出力ファイル名を `-o/--output`オプションにより必ず指定する必要があります。
	`+lhs`を`markdown`, `rst`, `latex`, `beamer`, `html`, `html5`のいずれかの後ろにつけ加えた場合、
	出力はLiterate Haskellソースコードとして出力されます （詳細は下記の[Literate Haskellのサポート](#literate-haskell-support)を参照）。
	Markdownの拡張文法は、`+EXTENSION` または `-EXTENSION` をフォーマット名の後ろにつけ加えることにより、
	それぞれ有効または無効を切り替えることができます（上記の `-f` セクションでの説明と同様）。


`-o` *FILE*, `--output=`*FILE*
:	標準出力 *stdout* に出力するのではなく、ファイル *FILE* へ出力するようにします。
	*FILE* として `-`を指定した場合、標準出力 *stdout*へ出力するようにします。
	（例外：出力フォーマットが`odt`, `docx`, `epub`, `epub3`のいずれかの場合、標準出力への出力は無効になります。）

`--data-dir=`*DIRECTORY*
:	Pandocデータファイルを検索するために、ユーザデータディレクトリを指定します。
	このオプションが指定されていない場合、デフォルトとして下記のユーザデータディレクトリが使用されます。

	デフォルトのユーザデータディレクトリは、Unixの場合は

        $HOME/.pandoc

    Windows XPの場合は

        C:\Documents And Settings\USERNAME\Application Data\pandoc

    Windows 7の場合は

        C:\Users\USERNAME\AppData\Roaming\pandoc

	です。（デフォルトのユーザデータディレクトリが分からない場合は、
	`pandoc --version`コマンドの出力の中から見つけることができます。）
	ユーザデータディレクトリに`reference.odt`, `reference.docx`, `default.csl`,
    `epub.css`ファイル、`templates`, `slidy`, `slideous`, `s5`ディレクトリを置いた場合、
	それらはPandocで通常使用されるのデフォルトのファイル・フォルダと置き換えられます。


`-v`, `--version`
:   バージョンを出力します。

`-h`, `--help`
:   使用方法を表示します。

Readerのオプション [reader-options]
----------------

`-R`, `--parse-raw`
:	解釈できないHTMLコードまたはLaTeX環境を無視する代わりに、
	生(raw)のHTMLまたはLaTeXソースとしてそのまま出力します。
	このオプションはHTMLまたはLaTeXソースの入力時のみに影響します。
	生のHTMLは出力がMarkdown, reStructuredText, HTML, Slidy, Slideous, DZSlides,
	reveal.js, S5の場合に表示され、
	生のLaTeXは出力がMarkdown, reStructuredText, LaTeX, ConTeXtの場合に表示されます。
	デフォルト動作では、Readerは解釈できないHTMLコードまたはLaTeX環境を無視します。
	（LaTeX Readerは、たとえ`-R`が指定されていない場合でも、LaTeX *コマンド* をそのまま出力します。）

`-S`, `--smart`
:	タイポグラフィ的に正しく出力します。
	具体的には、直線状の引用符を曲がった引用符に、`---`をemダッシュ「`—`」に、`--`をenダッシュ「`–`」に、 `...`を3点リーダーに変換します。
	また、"Mr."のようなある種の略記・略称に対しては、自動的な改行のないスペース(Nonbreaking Space)がその後に挿入されます。
	（注意：入力フォーマットが`markdown`, `markdown_strict`, `textile`の場合にこのオプションは重要です。
	また、入力フォーマットが`textile`の場合や出力ファイルが`latex`, `context`の場合は、
	`--no-tex-ligatures`を有効にしない限り、このオプションが有効になります。）

`--old-dashes`
:	ダッシュ記号の解釈をPandoc バージョン <= 1.8.2.1 の振る舞いと同等にします：
	数字の前の`-`をenダッシュに、`--`をemダッシュに変換します。
	このオプションは`textile`入力の際に自動的に選択されます。

`--base-header-level=`*NUMBER*
:	見出しのベースレベルを指定します（デフォルトは1）。
	（訳注：見出しのベースレベルは、HTMLにおける最上位の見出しレベルと対応します。
	例えば`--base-header-level=3`の場合は、HTMLの見出しが`<h3>`から始まります。）

`--indented-code-classes=`*CLASSES*
:	通常のインデントコードブロックに対して適用する構文強調表示用クラスを指定します。
	例えば、`perl,numberLines`や`haskell`のように指定します。複数のクラスを指定する場合は、スペースかコンマで区切ります。
	訳注：構文強調表示が可能な言語については下記の [訳注：構文強調表示が可能なプログラミング言語について](#code-highlighting) を参照して下さい。

`--default-image-extension=`*EXTENSION*
:	画像パス・URLの拡張子が無い場合のデフォルト拡張子を指定します。
	このコマンドにより、異なる種類の画像を必要とするフォーマットに対し、同一のソースを利用できるようになります。
	現在のところ、このオプションはMarkdownとLaTeXのReaderのみに影響を与えます。

`--filter=`*EXECUTABLE*
:	Pandocの入力処理と出力処理の間に挟んでPandoc ASTの変換処理を行うフィルタの実行ファイルを指定します。
	この実行ファイルは標準入力からJSONを読み、JSONを標準出力へ出力する必要があります。
	このJSONはPandoc自身の入力および出力のようなフォーマットでなければなりません。
	出力フォーマット名はフィルタへ第1引数として渡されます。したがって、

        pandoc --filter ./caps.py -t latex

	は以下と等価です：

        pandoc -t json | ./caps.py latex | pandoc -f json -t latex

	後者のコマンド形式はフィルタをデバッグする際に有用です。

	フィルタは任意の言語で書くことができます。Haskellでは`Text.Pandoc.JSON`は`toJSONFilter`をエクスポートし、Haskellでフィルタを書くことを容易にします。
	Pythonでフィルタを書きたい方は、モジュール`pandocfilters`をPyPIからインストールできます。このモジュールといくつかの例については、<http://github.com/jgm/pandocfilters>をご覧ください。
	注意：Pandocは実行ファイル*EXECUTABLE*をユーザの環境変数`PATH`から見つけますが、ディレクトリ名を明示していない場合、カレントディレクトリにある実行ファイルは無視されます。
	カレントディレクトリにあるスクリプトをフィルタとして実行したい場合は、そのスクリプト名の前に `./` を付けて下さい。

`-M` *KEY[=VAL]*, `--metadata=`*KEY[:VAL]*
:	メタデータとしてフィールド *KEY* に対し値 *VAL* をセットします。コマンドラインで指定された値は文書中の値を上書きします。
	値はYAMLのbooleanまたはstring値として解釈されます。値 *VAL* が指定されてない場合、その値はboolean値の`true`として見なされます。
	`--variable`や`--metadata`のようなオプションにより、テンプレート変数がセットされます。
	しかし、`--variable`とは違い、`--metadata`はその文書に内在するメタデータへ影響を与えます（このメタデータはフィルタからアクセス可能であり、ある出力フォーマットでは表示されることがあります）。


`--normalize`
:   入力処理の後に文書を簡素化します：例えば、隣接した`Str`や`Emph`要素をマージしたり、
	複数繰り返される`Space`を取り除いたりします。

`-p`, `--preserve-tabs`
:	このオプションを指定すると、タブ文字がスペースに変換されなくなります（デフォルトではタブ文字はスペースに変換されます）。
	注意：このオプションは文字通りのコード表示やコードブロックのみで有効です。通常のテキスト中のタブ文字はスペースとして扱われます。

`--tab-stop=`*NUMBER*
:	タブ文字をスペースに変換する際に、1つのタブ文字を何個のスペースで置換するかを指定します（デフォルト値は4）。

一般的なWriterオプション [general-writer-options]
----------------------

`-s`, `--standalone`
:	スタンドアローンモード。適切なヘッダおよびフッタのついた出力を生成します。（言い換えると、この出力は断片ではなく、1つの完全で独立したHTML, LaTeX, およびRTFファイルです。）
	このオプションは出力フォーマットが`pdf`, `epub`, `epub3`, `fb2`, `docx`, `odt`の場合に自動的に付加されます。
	訳注：このオプションは、Pandoc実行後にブラウザでHTMLファイルを表示させたり、LaTeXコマンドで直接ソースを処理したりする場合に必要となるでしょう。リッチテキストエディタでRTFファイルを扱う場合にはおそらく必須です。
	逆に、例えばブログなどに使う用途で最低限のHTMLだけが必要な場合は、このオプションを付けない方が用途にふさわしいでしょう。

`--template=`*FILE*
:	テンプレートファイル*FILE*をカスタムテンプレートとして出力文書に適用します。
	暗黙に`--standalone`オプションが指定されます。
	テンプレートの文法についての説明は、下記の [テンプレート](#templates) の節をご覧ください。
	拡張子が無い場合、Writerに対応する拡張子が *FILE* に追加されます。例えば、`--template=special`と指定すれば、PandocはHTML出力に対して`special.html`を探します。
	テンプレートファイルが見つからない場合、Pandocはユーザデータディレクトリを検索します（`--data-dir`を参照）。
	このオプションが使われない場合、出力に対してふさわしいデフォルトテンプレートが指定されます（`-D/--print-default-template`を参照）。


`-V` *KEY[=VAL]*, `--variable=`*KEY[:VAL]*
:	スタンドアローンモードで文書を出力する際に、テンプレート変数 *KEY* に対して値 *VAL* をセットします。
	Pandocはデフォルトテンプレートの中で変数を自動的に設定するため、
	このオプションはカスタムテンプレートを利用する際（`--template`オプションが指定されている場合）に有用です。
	値 *VAL* が何も指定されてない場合、*KEY*に対応する値として`true`が指定されます。

`-D` *FORMAT*, `--print-default-template=`*FORMAT*
:	出力フォーマット *FORMAT* で用いるデフォルトテンプレートを表示します。（指定できる *FORMAT* の一覧は `-t` の節を参照。）

`--print-default-data-file=`*FILE*
:	デフォルトのデータファイルを表示します。

`--no-wrap`
:	出力におけるテキストの折り返しを無効にします。デフォルトでは、テキストは出力フォーマットに応じて適切に折り返しされます。

`--columns`=*NUMBER*
:	1行あたりの文字数を指定します（テキストの折り返しに影響します）。

`--toc`, `--table-of-contents`
:	自動的に生成された目次を出力文書に含めます（`latex`, `context`, `rst`の場合は、目次を作成する命令を挿入します）。このオプションは、`man`, `docbook`, `slidy`, `slideous`, `s5`, `docx`, `odt`の場合は何も影響を与えません。

`--toc-depth=`*NUMBER*
:	目次に含める節のレベル番号を指定します。デフォルトは3です（つまり、レベル1, 2, 3の見出しが目次にリストアップされます）。

`--no-highlight`
:	コードブロックやインラインにおける構文強調表示を無効にします（構文強調表示用に言語が指定されている場合も同様です）。

`--highlight-style`=*STYLE*
:	ソースコードの構文強調表示に用いる色のスタイルを指定します。オプションは`pygments` (デフォルト値), `kate`, `monochrome`, `espresso`, `zenburn`, `haddock`, `tango`の中から選べます。
	訳注：これらのオプション値の名前の一部は実在の構文強調表示エンジンに由来しますが、そのエンジンを実際に使用するわけではなく、それに準じた色テーマを指定するだけです。

`-H` *FILE*, `--include-in-header=`*FILE*
:   ヘッダの末尾に、*FILE*の内容をそのままつけ加えます。
	使用例としては、HTMLヘッダに自前のCSSやJavaScriptのmetaタグをつけ加える用途に使えます。
	複数のファイルをヘッダに含めるために、このオプションを複数回指定することができます。オプションを指定した順番通りに、出力ファイルのヘッダへも追加されます。
	このオプションにより、`--standalone`も暗黙に指定されます。

`-B` *FILE*, `--include-before-body=`*FILE*
:	文書本文(body)の先頭に、*FILE*の内容をそのままつけ加えます（具体的には、HTMLの`<body>`タグの直後や、LaTeXの`\begin{document}`の直後です）。
	使用例としては、HTML文書にナビゲーションバーやバナーをつけ加える用途に使えます。
	複数のファイルを含めるために、このオプションを複数回指定することができます。オプションを指定した順番通りに、出力ファイルの文書本文先頭へも追加されます。
	このオプションにより、`--standalone`も暗黙に指定されます。

`-A` *FILE*, `--include-after-body=`*FILE*
:	文書本文(body)の末尾に、*FILE*の内容をそのままつけ加えます（具体的には、HTMLの`</body>`タグの直前や、LaTeXの`\end{document}`の直前です）。
	複数のファイルを含めるために、このオプションを複数回指定することができます。オプションを指定した順番通りに、出力ファイルの文書本文末尾へも追加されます。
	このオプションにより、`--standalone`も暗黙に指定されます。

特定のWriterに影響を与えるオプション  [options-affecting-specific-writers]
--------------------------------

`--self-contained`
:	他のファイルに依存せず、単一ファイルで完結したHTMLを生成します。
	リンクされたスクリプト、スタイルシート、画像および動画は、`data:` URIスキームを用いてHTMLファイル内に埋め込まれます。この出力ファイルは、一切の外部ファイルを必要とせず、ネットが繋がらない場所でも正しくブラウザで表示できるという意味では、自己完結した(self-contained)ファイルといえるでしょう。
	このオプションはHTMLに関連した出力フォーマットに対して有効であり、具体的には`html`, `html5`, `html+lhs`, `html5+lhs`, `s5`, `slidy`, `slideous`, `dzslides`, `revealjs`で用いることができます。
	絶対パスのURLで指定されたスクリプト、画像、スタイルシートはダウンロードされる一方で、相対パスのURLで指定されたそれらはまずカレントディレクトリから検索され、その後ユーザデータディレクトリから検索されます（`--data-dir`の節を参照）。最後に、Pandocのデフォルトデータディレクトリから検索されます。
	なお、`--self-contained`は`--mathjax`オプションと併用することができません。

`--offline`
:	*（非推奨）* `--self-contained`と等価。

`-5`, `--html5`
:	*（非推奨）* HTML4の代わりにHTML5で出力します。`html`以外の出力フォーマットでは無効です。
	現在はこのオプションの代わりに `html5` 出力フォーマットを利用するようにしてください。

`--html-q-tags`
:	HTMLで引用の際に `<q>` タグを利用します。

`--ascii`
:	ASCII文字のみを出力に利用します。現在のところHTML出力のみに対してサポートしています。（このオプションが指定されると、UTF-8の代わりに数値文字参照を利用します。）

`--reference-links`
:	MarkdownまたはreStructuredTextを出力する際に、インライン形式のリンクではなく参照形式のリンクを用いるようにします。デフォルトではインライン形式のリンクを出力します。
	（訳注：Markdownにおける各形式の詳細は [リンク](#links) の節をご覧ください。）

`--atx-headers`
:	MarkdownまたはAsciiDocを出力する際に、ATX形式の見出しを用いるようにします。デフォルトでは、レベル1-2の見出しに対してはSetext形式を、それ以降のレベルに対してはATX形式を用います。
	（訳注：Markdownにおける各形式の詳細は [ヘッダ](#headers) の節をご覧ください。）

`--chapters`
:	最も上位の見出しを章(chapter)として扱います。LaTeX, ConTeXt, DocBookの出力にて有効です。
	LaTeXのテンプレートがreport, book, memoirクラスファイルを用いる場合、このオプションが暗黙に指定されます。
	出力フォーマットとして`beamer`が指定された場合、最上位の見出しは`\part{..}`になります。

`-N`, `--number-sections`
:	番号付き節見出しを出力します。LaTeX, ConTeXt, HTML, EPUBの出力で有効です。
	デフォルトでは、節に番号は付いていません。`unnumbered`クラスのある節では、`--number-section`が指定されていている場合でも、番号は付きません。
	訳注1：例えば`\section{..}`に対して、`unnumbered`クラスとはLaTeXにおける`\section*{..}`、ConTeXtにおける`\subject{..}`だと思われます。
	訳注2：Pandocのデフォルトでは、`-s/--standalone`オプション付きでLaTeX出力すると、見出しに番号を付けない設定付きのLaTeXソースが出力されます。これはLaTeXそのもののデフォルトと異なるので注意して下さい。

`--number-offset`=*NUMBER[,NUMBER,...]*,
:	HTML出力中の節見出し番号に対して、指定されたオフセット値を加えます（他の出力フォーマットでは無視されます）。
	オフセット値はカンマ区切りで複数指定でき、最初の番号はトップレベルの見出しに対して、 2番目の番号は2番目のレベルの見出しに対して、というように指定できます。
	例えば、トップレベルの見出しを"6"から始めたい場合は、`--number-offset=5`と指定します。
	また、レベル2の見出しを"1.5"から始めたい場合は、`--number-offset=1,4`と指定します。
	オフセット値のデフォルトは0です。`--number-sections`を暗黙に指定します。

`--no-tex-ligatures`
:	LaTeXやConTeXtの出力において、引用符やアポストロフィ、ダッシュ記号をTeXの記号表記に変換しないようにします。
	その代わりに、Unicodeにおける各々の記号を文字通りに出力します。
	このオプションは、OpenTypeの高度な機能をXeLaTeXやLuaLaTeXで用いる際に必要となります。
	注意：通常、LaTeXとConTeXtの出力において `--smart` オプションが自動的に指定されます。しかし、`--no-tex-ligatures`を指定する場合は、`--smart`を明示的に指定しなければなりません。ただし、丸まった引用符やダッシュ記号、3点リーダー記号をソースコード内で用いる場合は、`--smart`を指定せずに`--no-tex-ligatures`を使う必要があるかもしれません。

`--listings`
:	LaTeXのコードブロックに対してlistingパッケージを適用します。

`-i`, `--incremental`
:	スライドショー内のリスト項目を一気に表示するのではなく1つずつ表示するようにします。
	デフォルトでは、リスト項目は全てが一気に表示されます。

`--slide-level`=*NUMBER*
:	指定したレベルの見出しごとに1枚ずつスライドを作るようにします（`beamer`, `s5`, `slidy`, `slideous`, `dzslides`で有効です）。
	このレベルよりも上の見出しはスライドショーを節ごとに区切るために使われます。また、このレベルよりも下の見出しはスライド内の副見出しを作ります。
	デフォルト値はドキュメントの内容によって変わります。詳しくは [スライドショーの構造を作る](#structuring-the-slide-show) をご覧ください。

`--section-divs`
:	HTMLでヘッダタグ（`<h1>`など）を使う代わりに、節を`<div>`タグ（HTML5では`<section>`タグ）で囲み、
	識別子を`<div>`（または`<section>`）タグの中に含めるようにします。
	詳しくは [ヘッダ識別子](#header-identifiers-in-html-latex-and-context) の項目をご覧ください。

`--email-obfuscation=`*none|javascript|references*
:	HTML文書において`mailto:`リンクを難読化する方法を指定します。
	*none*の場合は、リンクは難読化されません。*javascript*の場合はJavaScriptを用いて難読化します。
	*references*の場合は、メールアドレスの文字を10進または16進の数値参照により難読化します。

`--id-prefix`=*STRING*
:	HTMLとDocBookの出力において、自動的に生成される全ての識別子に対して付ける接頭辞(prefix)を指定します。
	または、Markdown出力においては、脚注番号に対して付ける接頭辞を指定します。
	このオプションは、文書の断片を生成し他の文書に埋め込む場合に、識別子が重複することを防ぐため便利です。

`-T` *STRING*, `--title-prefix=`*STRING*
:	HTMLヘッダの`<title>`タグの最初に現れる接頭辞(prefix)を指定します（ただしHTMLのbody部分の最初に現れるタイトルではありません）。`--standalone`を暗黙に指定します。

`-c` *URL*, `--css=`*URL*
:	スタイルシート(CSS)へのリンクを指定します。複数のスタイルシートを指定したい場合は、このオプションを繰り返し使用することもできます。オプションを指定した順に、スタイルシートも追加されます。

`--reference-odt=`*FILE*
:	OpenOffice/LibreOffice ODTファイルを出力する際に、スタイルの元となる参照用ODTファイルを使用します。ファイル名が指定されている場合は、そのファイルを参照用ODTファイルとして使用します。
	最も良い出力を得るために、参照用ODTファイルはPandocを用いて生成されたものを変更して使用して下さい。参照用ODTファイルの内容（コンテンツ）は無視され、そのスタイルシートが新しく出力されるODTファイルに適用されます。
	ODTファイルがコマンドラインに指定されていない場合、Pandocはユーザデータディレクトリから`reference.odt`という名前のファイルを検索します（`--data-dir`の節を参照）。もし見つからなければ、デフォルトの参照用ODTファイルを使います。
	訳注：カスタマイズの元になる参照用ODTファイルを得るには、
		`pandoc --print-default-data-file reference.odt > reference.odt`
	を実行して下さい。

`--reference-docx=`*FILE*
:	Word docxファイルを出力する際に、スタイルの元となる参照用docxファイルを使用します。ファイル名が指定されている場合は、そのファイルを参照用docxファイルとして使用します。
	最も良い出力を得るためには、参照用docxファイルはPandocを用いて生成されたものを変更して使用して下さい。参照用odocxファイルの内容（コンテンツ）は無視され、そのスタイルシートが新しく出力されるdocxファイルに適用されます。
	docxファイルがコマンドラインに指定されていない場合、Pandocはユーザデータディレクトリから`reference.docx`という名前のファイルを検索します（`--data-dir`の節を参照）。もし見つからなければ、デフォルトの参照用docxファイルを使います。
	Pandocでは以下のスタイルを使用します：[段落]
    標準(Normal), Compact, 表題(Title), Authors, 日付(Date), Heading 1, Heading 2, Heading 3,
    Heading 4, Heading 5, Block Quote, Definition Term, Definition,
    本文(Body Text), Table Caption, Image Caption; [文字] Default
    Paragraph Font, Body Text Char, Verbatim Char, Footnote Ref,
    Link.
	訳注：カスタマイズの元になる参照用docxファイルを得るには、
		`pandoc --print-default-data-file reference.docx > reference.docx`
	を実行して下さい。

`--epub-stylesheet=`*FILE*
:	EPUBでスタイルを整えるためにスタイルシート(CSS)を使用します。ファイル名が指定された場合はそれを使用し、指定されていない場合は`epub.css`という名前のファイルをユーザデータディレクトリから検索します（`--data-dir`の項を参照）。それでも見つからない場合は、デフォルトのスタイルシートを使用します。
	訳注：デフォルトのepub.cssを得るには、
		`pandoc --print-default-data-file epub.css > epub.css`
	を実行して下さい。

`--epub-cover-image=`*FILE*
:	EPUBのカバー画像として指定された画像を用います。
	画像は、縦と横が 1000px よりも小さいものを推奨します。
	注意：Markdownのソースファイル中では、YAMLメタデータブロックの中で`cover-image`を指定することもできます（下記の[EPUBメタデータ](#epub-metadata)を参照）。

`--epub-metadata=`*FILE*
:	EPUB出力の際に、指定されたEPUB用XMLメタデータを参照します。
	このファイルには<http://dublincore.org/documents/dces/>に記載されているDublin Core要素が含まれている必要があります。
	例：

         <dc:rights>Creative Commons</dc:rights>
         <dc:language>es-AR</dc:language>

	デフォルトでは、Pandocは以下のメタデータ要素を含みます：
	`<dc:title>` (文書のタイトルから取得),
	`<dc:creator>` (文書の著者名から取得),
	`<dc:date>` (文書の日付から取得, [ISO 8601 format]に従う必要があります),
	`<dc:language>` (変数 `lang` から取得, 設定されていない場合はロケールから取得),
	`<dc:identifier id="BookId">` (ランダムに生成されたUUID).

	注意：入力文書がMarkdownの場合、文書中のYAMLメタデータブロックが代わりに使用されます。詳しくは下記の[EPUBメタデータ](#epub-metadata)を参照してください。


`--epub-embed-font=`*FILE*
:	EPUBに指定したフォントを埋め込みます。複数のフォントを埋め込みたい場合は、このオプションを複数回使用することもできます。埋め込みフォントを利用するには、CSSファイルに以下のような宣言を追加する必要があります（`--epub-stylesheet`の項を参照）。

        @font-face {
        font-family: DejaVuSans;
        font-style: normal;
        font-weight: normal;
        src:url("DejaVuSans-Regular.ttf");
        }
        @font-face {
        font-family: DejaVuSans;
        font-style: normal;
        font-weight: bold;
        src:url("DejaVuSans-Bold.ttf");
        }
        @font-face {
        font-family: DejaVuSans;
        font-style: italic;
        font-weight: normal;
        src:url("DejaVuSans-Oblique.ttf");
        }
        @font-face {
        font-family: DejaVuSans;
        font-style: italic;
        font-weight: bold;
        src:url("DejaVuSans-BoldOblique.ttf");
        }
        body { font-family: "DejaVuSans"; }

`--epub-chapter-level=`*NUMBER*
:	EPUBファイルをいくつかの"chapter"（章）ファイルに分割するために、章に相当する見出しレベルを設定します。
	デフォルトでは、レベル1の見出しを使って複数の章に分割します。
	このオプションはEPUBファイルの内部構成に影響を与えるだけであり、ユーザに見せる章や節を制御するものではありません。
	いくつかのEPUBリーダーでは、chapterファイルのサイズが大きすぎる場合、動作が遅くなることがあります。少数のレベル1見出しを持つ大きな文書を変換する場合には、このオプションを使って章の見出しレベルを2または3に設定したくなるかもしれません。

`--latex-engine=`*pdflatex|lualatex|xelatex*
:	PDFを出力する際に、指定したLaTeXエンジンを利用します。デフォルトは`pdflatex`です。指定したエンジンがPATHの中に存在しない場合は、そのエンジンのフルパスを指定することもできます。
	訳注：日本語文書を処理する場合、特に理由が無ければ`lualatex`を利用するようにして下さい。

引用文献の表示   [citation-rendering]
-------------

`--bibliography=`*FILE*
:	文書中のメタデータにおいて`bibliography`フィールドを*FILE*で上書きし、
	`pandoc-citeproc`を用いて引用を処理します。（これは`--metadata bibliography=file --filter pandoc-citeproc`と等価です。）
	訳注：`bibliography`フィールドはBibTeXファイル(.bib)などの引用文献ファイルを指定するために利用します。詳細は下記の[文献の引用](#citations)をご覧ください。

`--csl=`*FILE*
:	文書中のメタデータにおいて`csl`フィールドを*FILE*で上書きします。（これは`--metadata csl=FILE`と等価です。）
	訳注：`csl`フィールドは引用の書式を指定するために利用します。詳細は下記の[文献の引用](#citations)をご覧ください。

`--citation-abbreviations=`*FILE*
:	文書中のメタデータにおいて`citation-abbreviations`フィールドを*FILE*で上書きします。（これは`--metadata citation-abbreviations=FILE`と等価です。）

`--natbib`
:	latex出力において、natbibパッケージを引用に利用します。

`--biblatex`
:	latex出力において、BibLaTeXを引用に利用します。

HTMLにおける数式の表示  [math-rendering-in-html]
--------------------

`-m` [*URL*], `--latexmathml`[=*URL*]
:	HTML出力において、[LaTeXMathML]スクリプトを用いて埋め込まれたTeX数式を表示します。
	ローカルの`LaTeXMathML.js`をリンクとして挿入したい場合は、*URL*を指定して下さい。
	*URL*が指定されていない場合は、効率を犠牲にして可搬性を向上させるために、スクリプトの内容をHTMLヘッダに直接挿入します。
	もし数式をいくつかのページに使うつもりであれば、スクリプトをリンクする方が良いでしょう（スクリプトがキャッシュされるため）。

`--mathml`[=*URL*]
:	`docbook`や`html`, `html5`において、TeX数式をMathMLに変換します。
	スタンドアローンの`html`出力では、MathMLをいくつかのブラウザで見られるようにするために、ヘッダに小さいJavaScriptを挿入します（*URL*が指定されている場合は、リンクを挿入します）。

`--jsmath`[=*URL*]
:	HTML出力において、埋め込まれたTeX数式を[jsMath]を用いて表示します。
	*URL*はjsMathのloadスクリプトである必要があり（例：`jsmath/easy/load.js`）、
	これを指定するとスタンドアローンなHTML文書のヘッダにリンクが埋め込まれます。
	*URL*が指定されていない場合は、jsMathのloadスクリプトへのリンクは挿入されないため、HTMLテンプレートなど別の手段を用いて適宜リンクを指定する必要があります。

`--mathjax`[=*URL*]
:	HTML出力において、埋め込まれたTeX数式を[MathJax]を用いて表示します。
	*URL*はMathJaxのloadスクリプト`MathJax.js`である必要があります。
	*URL*が指定されていない場合は、MathJax CDNへのリンクが挿入されます。

`--gladtex`
:	HTML出力において、TeX数式を`<eq>`タグで囲みます。
	これらの数式は[gladTeX]によって処理され、タイプセットされた画像へのリンクが生成されます。

`--mimetex`[=*URL*]
:	TeX数式を[mimeTeX]CGIスクリプトによって生成します。
	*URL*が指定されていない場合は、スクリプトが`/cgi-bin/mimetex.cgi`にあると仮定します。

`--webtex`[=*URL*]
:	TeX数式を外部スクリプトを用いて生成します。スクリプトはTeX数式を画像に変換するものに限ります。数式は指定されたURLで連結されます。*URL*が指定されていない場合は、Google Chart APIが使用されます。

ラッパースクリプトのためのオプション [options-for-wrapper-scripts]
------------------------------

`--dump-args`
:	コマンドライン引数に関する情報を標準出力*stdout*に出力し、終了します。
	このオプションは主にラッパースクリプトで使用するためのものです。
	出力の1行目は`-o`オプションで指定された出力ファイル名（出力ファイルを指定していない場合は標準出力の`-`）が表示されます。
	残りの行は引数で指定した順番に、引数1つにつき1行ずつ出力します。
	通常、標準のPandocオプションおよびその引数はこれらには含まれませんが、
	セパレータ`--`の後ろに付け足したオプションおよび引数に関しては出力されます。

`--ignore-args`
:	コマンドライン引数を無視します（ラッパースクリプトで使用するためのオプションです）。
	標準のPandocオプションは無視されません。例えば、

        pandoc --ignore-args -o foo.html -s foo.txt -- -e latin1

	は以下と等価です：

        pandoc -o foo.html -s

[LaTeXMathML]: http://math.etsu.edu/LaTeXMathML/
[jsMath]:  http://www.math.union.edu/~dpvc/jsmath/
[MathJax]: http://www.mathjax.org/
[gladTeX]:  http://ans.hsh.no/home/mgg/gladtex/
[mimeTeX]: http://www.forkosh.com/mimetex.html
[CSL]: http://CitationStyles.org

テンプレート [templates]
==========

When the `-s/--standalone` option is used, pandoc uses a template to
add header and footer material that is needed for a self-standing
document.  To see the default template that is used, just type

`-s/--standalone`オプションを使用している場合、Pandocは完全で独立した文書を生成するために、

    pandoc -D FORMAT

where `FORMAT` is the name of the output format. A custom template
can be specified using the `--template` option.  You can also override
the system default templates for a given output format `FORMAT`
by putting a file `templates/default.FORMAT` in the user data
directory (see `--data-dir`, above). *Exceptions:* For `odt` output,
customize the `default.opendocument` template.  For `pdf` output,
customize the `default.latex` template.

Templates may contain *variables*.  Variable names are sequences of
alphanumerics, `-`, and `_`, starting with a letter.  A variable name
surrounded by `$` signs will be replaced by its value.  For example,
the string `$title$` in

    <title>$title$</title>

will be replaced by the document title.

To write a literal `$` in a template, use `$$`.

Some variables are set automatically by pandoc.  These vary somewhat
depending on the output format, but include metadata fields (such
as `title`, `author`, and `date`) as well as the following:

`header-includes`
:   contents specified by `-H/--include-in-header` (may have multiple
    values)

`toc`
:   non-null value if `--toc/--table-of-contents` was specified

`include-before`
:   contents specified by `-B/--include-before-body` (may have
    multiple values)

`include-after`
:   contents specified by `-A/--include-after-body` (may have
    multiple values)

`body`
:   body of document

`lang`
:   language code for HTML or LaTeX documents

`slidy-url`
:   base URL for Slidy documents (defaults to
    `http://www.w3.org/Talks/Tools/Slidy2`)

`slideous-url`
:   base URL for Slideous documents (defaults to `default`)

`s5-url`
:   base URL for S5 documents (defaults to `ui/default`)

`revealjs-url`
:   base URL for reveal.js documents (defaults to `reveal.js`)

`theme`
:   reveal.js or LaTeX beamer theme

`transition`
:   reveal.js transition

`fontsize`
:   font size (10pt, 11pt, 12pt) for LaTeX documents

`documentclass`
:   document class for LaTeX documents

`classoption`
:   option for LaTeX documentclass, e.g. `oneside`; may be repeated
    for multiple options

`geometry`
:   options for LaTeX `geometry` class, e.g. `margin=1in`;
    may be repeated for multiple options

`mainfont`, `sansfont`, `monofont`, `mathfont`
:   fonts for LaTeX documents (works only with xelatex
    and lualatex)

`colortheme`
:   colortheme for LaTeX beamer documents

`fonttheme`
:   fonttheme for LaTeX beamer documents

`linkcolor`
:   color for internal links in LaTeX documents (`red`, `green`,
    `magenta`, `cyan`, `blue`, `black`)

`urlcolor`
:   color for external links in LaTeX documents

`citecolor`
:   color for citation links in LaTeX documents

`links-as-notes`
:   causes links to be printed as footnotes in LaTeX documents

`biblio-style`
:   bibliography style in LaTeX, when used with `--natbib`

`section`
:   section number in man pages

`header`
:   header in man pages

`footer`
:   footer in man pages

Variables may be set at the command line using the `-V/--variable`
option.  Variables set in this way override metadata fields with
the same name.

Templates may contain conditionals.  The syntax is as follows:

    $if(variable)$
    X
    $else$
    Y
    $endif$

This will include `X` in the template if `variable` has a non-null
value; otherwise it will include `Y`. `X` and `Y` are placeholders for
any valid template text, and may include interpolated variables or other
conditionals. The `$else$` section may be omitted.

When variables can have multiple values (for example, `author` in
a multi-author document), you can use the `$for$` keyword:

    $for(author)$
    <meta name="author" content="$author$" />
    $endfor$

You can optionally specify a separator to be used between
consecutive items:

    $for(author)$$author$$sep$, $endfor$

A dot can be used to select a field of a variable that takes
an object as its value.  So, for example:

    $author.name$ ($author.affiliation$)

If you use custom templates, you may need to revise them as pandoc
changes.  We recommend tracking the changes in the default templates,
and modifying your custom templates accordingly. An easy way to do this
is to fork the pandoc-templates repository
(<http://github.com/jgm/pandoc-templates>) and merge in changes after each
pandoc release.

Pandocによる拡張Markdown [pandocs-markdown]
=======================

Pandoc understands an extended and slightly revised version of
John Gruber's [markdown] syntax.  This document explains the syntax,
noting differences from standard markdown. Except where noted, these
differences can be suppressed by using the `markdown_strict` format instead
of `markdown`.  An extensions can be enabled by adding `+EXTENSION`
to the format name and disabled by adding `-EXTENSION`. For example,
`markdown_strict+footnotes` is strict markdown with footnotes
enabled, while `markdown-footnotes-pipe_tables` is pandoc's
markdown without footnotes or pipe tables.

Philosophy
----------

Markdown is designed to be easy to write, and, even more importantly,
easy to read:

> A Markdown-formatted document should be publishable as-is, as plain
> text, without looking like it's been marked up with tags or formatting
> instructions.
> -- [John Gruber](http://daringfireball.net/projects/markdown/syntax#philosophy)

This principle has guided pandoc's decisions in finding syntax for
tables, footnotes, and other extensions.

There is, however, one respect in which pandoc's aims are different
from the original aims of markdown.  Whereas markdown was originally
designed with HTML generation in mind, pandoc is designed for multiple
output formats.  Thus, while pandoc allows the embedding of raw HTML,
it discourages it, and provides other, non-HTMLish ways of representing
important document elements like definition lists, tables, mathematics, and
footnotes.

Paragraphs
----------

A paragraph is one or more lines of text followed by one or more blank line.
Newlines are treated as spaces, so you can reflow your paragraphs as you like.
If you need a hard line break, put two or more spaces at the end of a line.

**Extension: `escaped_line_breaks`**

A backslash followed by a newline is also a hard line break.

ヘッダ  [headers]
-------

There are two kinds of headers, Setext and atx.

### Setext-style headers ###

A setext-style header is a line of text "underlined" with a row of `=` signs
(for a level one header) or `-` signs (for a level two header):

    A level-one header
    ==================

    A level-two header
    ------------------

The header text can contain inline formatting, such as emphasis (see
[Inline formatting](#inline-formatting), below).


### Atx-style headers ###

An Atx-style header consists of one to six `#` signs and a line of
text, optionally followed by any number of `#` signs.  The number of
`#` signs at the beginning of the line is the header level:

    ## A level-two header

    ### A level-three header ###

As with setext-style headers, the header text can contain formatting:

    # A level-one header with a [link](/url) and *emphasis*

**Extension: `blank_before_header`**

Standard markdown syntax does not require a blank line before a header.
Pandoc does require this (except, of course, at the beginning of the
document). The reason for the requirement is that it is all too easy for a
`#` to end up at the beginning of a line by accident (perhaps through line
wrapping). Consider, for example:

    I like several of their flavors of ice cream:
    #22, for example, and #5.


### Header identifiers in HTML, LaTeX, and ConTeXt ###

**Extension: `header_attributes`**

Headers can be assigned attributes using this syntax at the end
of the line containing the header text:

    {#identifier .class .class key=value key=value}

Although this syntax allows assignment of classes and key/value attributes,
only identifiers currently have any affect in the writers (and only in some
writers: HTML, LaTeX, ConTeXt, Textile, AsciiDoc).  Thus, for example,
the following headers will all be assigned the identifier `foo`:

    # My header {#foo}

    ## My header ##    {#foo}

    My other header   {#foo}
    ---------------

(This syntax is compatible with [PHP Markdown Extra].)

Headers with the class `unnumbered` will not be numbered, even if
`--number-sections` is specified.  A single hyphen (`-`) in an attribute
context is equivalent to `.unnumbered`, and preferable in non-English
documents.  So,

    # My header {-}

is just the same as

    # My header {.unnumbered}

**Extension: `auto_identifiers`**

A header without an explicitly specified identifier will be
automatically assigned a unique identifier based on the header text.
To derive the identifier from the header text,

  - Remove all formatting, links, etc.
  - Remove all footnotes.
  - Remove all punctuation, except underscores, hyphens, and periods.
  - Replace all spaces and newlines with hyphens.
  - Convert all alphabetic characters to lowercase.
  - Remove everything up to the first letter (identifiers may
    not begin with a number or punctuation mark).
  - If nothing is left after this, use the identifier `section`.

Thus, for example,

  Header                            Identifier
  -------------------------------   ----------------------------
  Header identifiers in HTML        `header-identifiers-in-html`
  *Dogs*?--in *my* house?           `dogs--in-my-house`
  [HTML], [S5], or [RTF]?           `html-s5-or-rtf`
  3. Applications                   `applications`
  33                                `section`

These rules should, in most cases, allow one to determine the identifier
from the header text. The exception is when several headers have the
same text; in this case, the first will get an identifier as described
above; the second will get the same identifier with `-1` appended; the
third with `-2`; and so on.

These identifiers are used to provide link targets in the table of
contents generated by the `--toc|--table-of-contents` option. They
also make it easy to provide links from one section of a document to
another. A link to this section, for example, might look like this:

    See the section on
    [header identifiers](#header-identifiers-in-html-latex-and-context).

Note, however, that this method of providing links to sections works
only in HTML, LaTeX, and ConTeXt formats.

If the `--section-divs` option is specified, then each section will
be wrapped in a `div` (or a `section`, if `--html5` was specified),
and the identifier will be attached to the enclosing `<div>`
(or `<section>`) tag rather than the header itself. This allows entire
sections to be manipulated using javascript or treated differently in
CSS.

**Extension: `implicit_header_references`**

Pandoc behaves as if reference links have been defined for each header.
So, instead of

    [header identifiers](#header-identifiers-in-html)

you can simply write

    [header identifiers]

or

    [header identifiers][]

or

    [the section on header identifiers][header identifiers]

If there are multiple headers with identical text, the corresponding
reference will link to the first one only, and you will need to use explicit
links to link to the others, as described above.

Unlike regular reference links, these references are case-sensitive.

Note:  if you have defined an explicit identifier for a header,
then implicit references to it will not work.

Block quotations
----------------

Markdown uses email conventions for quoting blocks of text.
A block quotation is one or more paragraphs or other block elements
(such as lists or headers), with each line preceded by a `>` character
and a space. (The `>` need not start at the left margin, but it should
not be indented more than three spaces.)

    > This is a block quote. This
    > paragraph has two lines.
    >
    > 1. This is a list inside a block quote.
    > 2. Second item.

A "lazy" form, which requires the `>` character only on the first
line of each block, is also allowed:

    > This is a block quote. This
    paragraph has two lines.

    > 1. This is a list inside a block quote.
    2. Second item.

Among the block elements that can be contained in a block quote are
other block quotes. That is, block quotes can be nested:

    > This is a block quote.
    >
    > > A block quote within a block quote.

**Extension: `blank_before_blockquote`**

Standard markdown syntax does not require a blank line before a block
quote.  Pandoc does require this (except, of course, at the beginning of the
document). The reason for the requirement is that it is all too easy for a
`>` to end up at the beginning of a line by accident (perhaps through line
wrapping). So, unless the `markdown_strict` format is used, the following does
not produce a nested block quote in pandoc:

    > This is a block quote.
    >> Nested.


Verbatim (code) blocks
----------------------

### Indented code blocks ###

A block of text indented four spaces (or one tab) is treated as verbatim
text: that is, special characters do not trigger special formatting,
and all spaces and line breaks are preserved.  For example,

        if (a > 3) {
          moveShip(5 * gravity, DOWN);
        }

The initial (four space or one tab) indentation is not considered part
of the verbatim text, and is removed in the output.

Note: blank lines in the verbatim text need not begin with four spaces.


### Fenced code blocks ###

**Extension: `fenced_code_blocks`**

In addition to standard indented code blocks, Pandoc supports
*fenced* code blocks.  These begin with a row of three or more
tildes (`~`) or backticks (`` ` ``) and end with a row of tildes or
backticks that must be at least as long as the starting row. Everything
between these lines is treated as code. No indentation is necessary:

    ~~~~~~~
    if (a > 3) {
      moveShip(5 * gravity, DOWN);
    }
    ~~~~~~~

Like regular code blocks, fenced code blocks must be separated
from surrounding text by blank lines.

If the code itself contains a row of tildes or backticks, just use a longer
row of tildes or backticks at the start and end:

    ~~~~~~~~~~~~~~~~
    ~~~~~~~~~~
    code including tildes
    ~~~~~~~~~~
    ~~~~~~~~~~~~~~~~

Optionally, you may attach attributes to the code block using
this syntax:

    ~~~~ {#mycode .haskell .numberLines startFrom="100"}
    qsort []     = []
    qsort (x:xs) = qsort (filter (< x) xs) ++ [x] ++
                   qsort (filter (>= x) xs)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here `mycode` is an identifier, `haskell` and `numberLines` are classes, and
`startFrom` is an attribute with value `100`. Some output formats can use this
information to do syntax highlighting. Currently, the only output formats
that uses this information are HTML and LaTeX. If highlighting is supported
for your output format and language, then the code block above will appear
highlighted, with numbered lines. (To see which languages are supported, do
`pandoc --version`.) Otherwise, the code block above will appear as follows:

    <pre id="mycode" class="haskell numberLines" startFrom="100">
      <code>
      ...
      </code>
    </pre>

A shortcut form can also be used for specifying the language of
the code block:

    ```haskell
    qsort [] = []
    ```

This is equivalent to:

    ``` {.haskell}
    qsort [] = []
    ```

To prevent all highlighting, use the `--no-highlight` flag.
To set the highlighting style, use `--highlight-style`.

### 訳注：構文強調表示が可能なプログラミング言語について [code-highlighting]

このドキュメントの原文では明示されていませんが、 構文強調表示可能なプログラミング言語の種類は、
pandoc作者のjohn macfarlaneが同じく作成した[highlighting-kate]に依存します。

highlighting-kateで利用可能な言語は以下の通りです：
actionscript, ada, apache, asn1, asp, awk, bash, bibtex, boo,
c, changelog, clojure, cmake, coffee, coldfusion, commonlisp, cpp, cs, css, curry,
d, diff, djangotemplate, doxygen, doxygenlua, dtd, eiffel, email, erlang,
fortran, fsharp, gnuassembler, go, haskell, haxe, html, ini, java, javadoc,
javascript, json, jsp, julia, latex, lex, literatecurry, literatehaskell, lua,
makefile, mandoc, matlab, maxima, metafont, mips, modula2, modula3, monobasic,
nasm, noweb, objectivec, objectivecpp, ocaml, octave, pascal, perl, php, pike,
postscript, prolog, python, r, relaxngcompact, rhtml, ruby, rust, scala, scheme,
sci, sed, sgml, sql, sqlmysql, sqlpostgresql, tcl, texinfo, verilog, vhdl,
xml, xorg, xslt, xul, yacc, yaml.

[highlighting-kate]: http://johnmacfarlane.net/highlighting-kate/


Line blocks
-----------

**Extension: `line_blocks`**

A line block is a sequence of lines beginning with a vertical bar (`|`)
followed by a space.  The division into lines will be preserved in
the output, as will any leading spaces; otherwise, the lines will
be formatted as markdown.  This is useful for verse and addresses:

    | The limerick packs laughs anatomical
    | In space that is quite economical.
    |    But the good ones I've seen
    |    So seldom are clean
    | And the clean ones so seldom are comical

    | 200 Main St.
    | Berkeley, CA 94718

The lines can be hard-wrapped if needed, but the continuation
line must begin with a space.

    | The Right Honorable Most Venerable and Righteous Samuel L.
      Constable, Jr.
    | 200 Main St.
    | Berkeley, CA 94718

This syntax is borrowed from [reStructuredText].

Lists
-----

### Bullet lists ###

A bullet list is a list of bulleted list items.  A bulleted list
item begins with a bullet (`*`, `+`, or `-`).  Here is a simple
example:

    * one
    * two
    * three

This will produce a "compact" list. If you want a "loose" list, in which
each item is formatted as a paragraph, put spaces between the items:

    * one

    * two

    * three

The bullets need not be flush with the left margin; they may be
indented one, two, or three spaces. The bullet must be followed
by whitespace.

List items look best if subsequent lines are flush with the first
line (after the bullet):

    * here is my first
      list item.
    * and my second.

But markdown also allows a "lazy" format:

    * here is my first
    list item.
    * and my second.

### The four-space rule ###

A list item may contain multiple paragraphs and other block-level
content. However, subsequent paragraphs must be preceded by a blank line
and indented four spaces or a tab. The list will look better if the first
paragraph is aligned with the rest:

      * First paragraph.

        Continued.

      * Second paragraph. With a code block, which must be indented
        eight spaces:

            { code }

List items may include other lists.  In this case the preceding blank
line is optional.  The nested list must be indented four spaces or
one tab:

    * fruits
        + apples
            - macintosh
            - red delicious
        + pears
        + peaches
    * vegetables
        + brocolli
        + chard

As noted above, markdown allows you to write list items "lazily," instead of
indenting continuation lines. However, if there are multiple paragraphs or
other blocks in a list item, the first line of each must be indented.

    + A lazy, lazy, list
    item.

    + Another one; this looks
    bad but is legal.

        Second paragraph of second
    list item.

**Note:**  Although the four-space rule for continuation paragraphs
comes from the official [markdown syntax guide], the reference implementation,
`Markdown.pl`, does not follow it. So pandoc will give different results than
`Markdown.pl` when authors have indented continuation paragraphs fewer than
four spaces.

The [markdown syntax guide] is not explicit whether the four-space
rule applies to *all* block-level content in a list item; it only
mentions paragraphs and code blocks.  But it implies that the rule
applies to all block-level content (including nested lists), and
pandoc interprets it that way.

  [markdown syntax guide]:
    http://daringfireball.net/projects/markdown/syntax#list

### Ordered lists ###

Ordered lists work just like bulleted lists, except that the items
begin with enumerators rather than bullets.

In standard markdown, enumerators are decimal numbers followed
by a period and a space.  The numbers themselves are ignored, so
there is no difference between this list:

    1.  one
    2.  two
    3.  three

and this one:

    5.  one
    7.  two
    1.  three

**Extension: `fancy_lists`**

Unlike standard markdown, Pandoc allows ordered list items to be marked
with uppercase and lowercase letters and roman numerals, in addition to
arabic numerals. List markers may be enclosed in parentheses or followed by a
single right-parentheses or period. They must be separated from the
text that follows by at least one space, and, if the list marker is a
capital letter with a period, by at least two spaces.[^2]

[^2]:  The point of this rule is to ensure that normal paragraphs
    starting with people's initials, like

        B. Russell was an English philosopher.

    do not get treated as list items.

    This rule will not prevent

        (C) 2007 Joe Smith

    from being interpreted as a list item.  In this case, a backslash
    escape can be used:

        (C\) 2007 Joe Smith

The `fancy_lists` extension also allows '`#`' to be used as an
ordered list marker in place of a numeral:

    #. one
    #. two

**Extension: `startnum`**

Pandoc also pays attention to the type of list marker used, and to the
starting number, and both of these are preserved where possible in the
output format. Thus, the following yields a list with numbers followed
by a single parenthesis, starting with 9, and a sublist with lowercase
roman numerals:

     9)  Ninth
    10)  Tenth
    11)  Eleventh
           i. subone
          ii. subtwo
         iii. subthree

Pandoc will start a new list each time a different type of list
marker is used.  So, the following will create three lists:

    (2) Two
    (5) Three
    1.  Four
    *   Five

If default list markers are desired, use `#.`:

    #.  one
    #.  two
    #.  three


### Definition lists ###

**Extension: `definition_lists`**

Pandoc supports definition lists, using a syntax inspired by
[PHP Markdown Extra] and [reStructuredText]:[^3]

    Term 1

    :   Definition 1

    Term 2 with *inline markup*

    :   Definition 2

            { some code, part of Definition 2 }

        Third paragraph of definition 2.

Each term must fit on one line, which may optionally be followed by
a blank line, and must be followed by one or more definitions.
A definition begins with a colon or tilde, which may be indented one
or two spaces. The body of the definition (including the first line,
aside from the colon or tilde) should be indented four spaces. A term may have
multiple definitions, and each definition may consist of one or more block
elements (paragraph, code block, list, etc.), each indented four spaces or one
tab stop.

If you leave space after the definition (as in the example above),
the blocks of the definitions will be considered paragraphs. In some
output formats, this will mean greater spacing between term/definition
pairs. For a compact definition list, do not leave space between the
definition and the next term:

    Term 1
      ~ Definition 1
    Term 2
      ~ Definition 2a
      ~ Definition 2b

[^3]:  I have also been influenced by the suggestions of [David Wheeler](http://www.justatheory.com/computers/markup/modest-markdown-proposal.html).

[PHP Markdown Extra]: http://www.michelf.com/projects/php-markdown/extra/


### Numbered example lists ###

**Extension: `example_lists`**

The special list marker `@` can be used for sequentially numbered
examples. The first list item with a `@` marker will be numbered '1',
the next '2', and so on, throughout the document. The numbered examples
need not occur in a single list; each new list using `@` will take up
where the last stopped. So, for example:

    (@)  My first example will be numbered (1).
    (@)  My second example will be numbered (2).

    Explanation of examples.

    (@)  My third example will be numbered (3).

Numbered examples can be labeled and referred to elsewhere in the
document:

    (@good)  This is a good example.

    As (@good) illustrates, ...

The label can be any string of alphanumeric characters, underscores,
or hyphens.



### Compact and loose lists ###

Pandoc behaves differently from `Markdown.pl` on some "edge
cases" involving lists.  Consider this source:

    +   First
    +   Second:
    	-   Fee
    	-   Fie
    	-   Foe

    +   Third

Pandoc transforms this into a "compact list" (with no `<p>` tags around
"First", "Second", or "Third"), while markdown puts `<p>` tags around
"Second" and "Third" (but not "First"), because of the blank space
around "Third". Pandoc follows a simple rule: if the text is followed by
a blank line, it is treated as a paragraph. Since "Second" is followed
by a list, and not a blank line, it isn't treated as a paragraph. The
fact that the list is followed by a blank line is irrelevant. (Note:
Pandoc works this way even when the `markdown_strict` format is specified. This
behavior is consistent with the official markdown syntax description,
even though it is different from that of `Markdown.pl`.)


### Ending a list ###

What if you want to put an indented code block after a list?

    -   item one
    -   item two

        { my code block }

Trouble! Here pandoc (like other markdown implementations) will treat
`{ my code block }` as the second paragraph of item two, and not as
a code block.

To "cut off" the list after item two, you can insert some non-indented
content, like an HTML comment, which won't produce visible output in
any format:

    -   item one
    -   item two

    <!-- end of list -->

        { my code block }

You can use the same trick if you want two consecutive lists instead
of one big list:

    1.  one
    2.  two
    3.  three

    <!-- -->

    1.  uno
    2.  dos
    3.  tres

Horizontal rules
----------------

A line containing a row of three or more `*`, `-`, or `_` characters
(optionally separated by spaces) produces a horizontal rule:

    *  *  *  *

    ---------------


Tables
------

Four kinds of tables may be used. The first three kinds presuppose the use of
a fixed-width font, such as Courier. The fourth kind can be used with
proportionally spaced fonts, as it does not require lining up columns.

### Simple tables

**Extension: `simple_tables`, `table_captions`**

Simple tables look like this:

      Right     Left     Center     Default
    -------     ------ ----------   -------
         12     12        12            12
        123     123       123          123
          1     1          1             1

    Table:  Demonstration of simple table syntax.

The headers and table rows must each fit on one line.  Column
alignments are determined by the position of the header text relative
to the dashed line below it:[^4]

  - If the dashed line is flush with the header text on the right side
    but extends beyond it on the left, the column is right-aligned.
  - If the dashed line is flush with the header text on the left side
    but extends beyond it on the right, the column is left-aligned.
  - If the dashed line extends beyond the header text on both sides,
    the column is centered.
  - If the dashed line is flush with the header text on both sides,
    the default alignment is used (in most cases, this will be left).

[^4]:  This scheme is due to Michel Fortin, who proposed it on the
       [Markdown discussion list](http://six.pairlist.net/pipermail/markdown-discuss/2005-March/001097.html).

The table must end with a blank line, or a line of dashes followed by
a blank line.  A caption may optionally be provided (as illustrated in
the example above). A caption is a paragraph beginning with the string
`Table:` (or just `:`), which will be stripped off. It may appear either
before or after the table.

The column headers may be omitted, provided a dashed line is used
to end the table. For example:

    -------     ------ ----------   -------
         12     12        12             12
        123     123       123           123
          1     1          1              1
    -------     ------ ----------   -------

When headers are omitted, column alignments are determined on the basis
of the first line of the table body. So, in the tables above, the columns
would be right, left, center, and right aligned, respectively.

### Multiline tables

**Extension: `multiline_tables`, `table_captions`**

Multiline tables allow headers and table rows to span multiple lines
of text (but cells that span multiple columns or rows of the table are
not supported).  Here is an example:

    -------------------------------------------------------------
     Centered   Default           Right Left
      Header    Aligned         Aligned Aligned
    ----------- ------- --------------- -------------------------
       First    row                12.0 Example of a row that
                                        spans multiple lines.

      Second    row                 5.0 Here's another one. Note
                                        the blank line between
                                        rows.
    -------------------------------------------------------------

    Table: Here's the caption. It, too, may span
    multiple lines.

These work like simple tables, but with the following differences:

  - They must begin with a row of dashes, before the header text
    (unless the headers are omitted).
  - They must end with a row of dashes, then a blank line.
  - The rows must be separated by blank lines.

In multiline tables, the table parser pays attention to the widths of
the columns, and the writers try to reproduce these relative widths in
the output. So, if you find that one of the columns is too narrow in the
output, try widening it in the markdown source.

Headers may be omitted in multiline tables as well as simple tables:

    ----------- ------- --------------- -------------------------
       First    row                12.0 Example of a row that
                                        spans multiple lines.

      Second    row                 5.0 Here's another one. Note
                                        the blank line between
                                        rows.
    ----------- ------- --------------- -------------------------

    : Here's a multiline table without headers.

It is possible for a multiline table to have just one row, but the row
should be followed by a blank line (and then the row of dashes that ends
the table), or the table may be interpreted as a simple table.

### Grid tables

**Extension: `grid_tables`, `table_captions`**

Grid tables look like this:

    : Sample grid table.

    +---------------+---------------+--------------------+
    | Fruit         | Price         | Advantages         |
    +===============+===============+====================+
    | Bananas       | $1.34         | - built-in wrapper |
    |               |               | - bright color     |
    +---------------+---------------+--------------------+
    | Oranges       | $2.10         | - cures scurvy     |
    |               |               | - tasty            |
    +---------------+---------------+--------------------+

The row of `=`s separates the header from the table body, and can be
omitted for a headerless table. The cells of grid tables may contain
arbitrary block elements (multiple paragraphs, code blocks, lists,
etc.). Alignments are not supported, nor are cells that span multiple
columns or rows. Grid tables can be created easily using [Emacs table mode].

  [Emacs table mode]: http://table.sourceforge.net/

### Pipe tables

**Extension: `pipe_tables`, `table_captions`**

Pipe tables look like this:

    | Right | Left | Default | Center |
    |------:|:-----|---------|:------:|
    |   12  |  12  |    12   |    12  |
    |  123  |  123 |   123   |   123  |
    |    1  |    1 |     1   |     1  |

      : Demonstration of simple table syntax.

The syntax is [the same as in PHP markdown extra].  The beginning and
ending pipe characters are optional, but pipes are required between all
columns.  The colons indicate column alignment as shown.  The header
can be omitted, but the horizontal line must still be included, as
it defines column alignments.

Since the pipes indicate column boundaries, columns need not be vertically
aligned, as they are in the above example.  So, this is a perfectly
legal (though ugly) pipe table:

    fruit| price
    -----|-----:
    apple|2.05
    pear|1.37
    orange|3.09

The cells of pipe tables cannot contain block elements like paragraphs
and lists, and cannot span multiple lines.

  [the same as in PHP markdown extra]:
    http://michelf.ca/projects/php-markdown/extra/#table

Note:  Pandoc also recognizes pipe tables of the following
form, as can produced by Emacs' orgtbl-mode:

    | One | Two   |
    |-----+-------|
    | my  | table |
    | is  | nice  |

The difference is that `+` is used instead of `|`. Other orgtbl features
are not supported. In particular, to get non-default column alignment,
you'll need to add colons as above.

Title block
-----------

**Extension: `pandoc_title_block`**

If the file begins with a title block

    % title
    % author(s) (separated by semicolons)
    % date

it will be parsed as bibliographic information, not regular text.  (It
will be used, for example, in the title of standalone LaTeX or HTML
output.)  The block may contain just a title, a title and an author,
or all three elements. If you want to include an author but no
title, or a title and a date but no author, you need a blank line:

    %
    % Author

    % My title
    %
    % June 15, 2006

The title may occupy multiple lines, but continuation lines must
begin with leading space, thus:

    % My title
      on multiple lines

If a document has multiple authors, the authors may be put on
separate lines with leading space, or separated by semicolons, or
both.  So, all of the following are equivalent:

    % Author One
      Author Two

    % Author One; Author Two

    % Author One;
      Author Two

The date must fit on one line.

All three metadata fields may contain standard inline formatting
(italics, links, footnotes, etc.).

Title blocks will always be parsed, but they will affect the output only
when the `--standalone` (`-s`) option is chosen. In HTML output, titles
will appear twice: once in the document head -- this is the title that
will appear at the top of the window in a browser -- and once at the
beginning of the document body. The title in the document head can have
an optional prefix attached (`--title-prefix` or `-T` option). The title
in the body appears as an H1 element with class "title", so it can be
suppressed or reformatted with CSS. If a title prefix is specified with
`-T` and no title block appears in the document, the title prefix will
be used by itself as the HTML title.

The man page writer extracts a title, man page section number, and
other header and footer information from the title line. The title
is assumed to be the first word on the title line, which may optionally
end with a (single-digit) section number in parentheses. (There should
be no space between the title and the parentheses.)  Anything after
this is assumed to be additional footer and header text. A single pipe
character (`|`) should be used to separate the footer text from the header
text.  Thus,

    % PANDOC(1)

will yield a man page with the title `PANDOC` and section 1.

    % PANDOC(1) Pandoc User Manuals

will also have "Pandoc User Manuals" in the footer.

    % PANDOC(1) Pandoc User Manuals | Version 4.0

will also have "Version 4.0" in the header.

YAML metadata block
-------------------

**Extension: `yaml_metadata_block`**

A YAML metadata block is a valid YAML object, delimited by a line of three
hyphens (`---`) at the top and a line of three hyphens (`---`) or three dots
(`...`) at the bottom.  A YAML metadata block may occur anywhere in the
document, but if it is not at the beginning, it must be preceded by a blank
line.

Metadata will be taken from the fields of the YAML object and added to any
existing document metadata.  Metadata can contain lists and objects (nested
arbitrarily), but all string scalars will be interpreted as markdown.  Fields
with names ending in an underscore will be ignored by pandoc.  (They may be
given a role by external processors.)

A document may contain multiple metadata blocks.  The metadata fields will
be combined through a *left-biased union*:  if two metadata blocks attempt
to set the same field, the value from the first block will be taken.

Note that YAML escaping rules must be followed. Thus, for example,
if a title contains a colon, it must be quoted.  The pipe character
(`|`) can be used to begin an indented block that will be interpreted
literally, without need for escaping.  This form is necessary
when the field contains blank lines:

    ---
    title:  'This is the title: it contains a colon'
    author:
    - name: Author One
      affiliation: University of Somewhere
    - name: Author Two
      affiliation: University of Nowhere
    tags: [nothing, nothingness]
    abstract: |
      This is the abstract.

      It consists of two paragraphs.
    ...

Template variables will be set automatically from the metadata.  Thus, for
example, in writing HTML, the variable `abstract` will be set to the HTML
equivalent of the markdown in the `abstract` field:

    <p>This is the abstract.</p>
    <p>It consists of two paragraphs.</p>

Note:  The example above will not work with the default templates.
The `author` variable in the templates expects a simple list or string,
and there is no `abstract` variable in most templates.  To use these,
you would need to use a custom template with appropriate variables.
For example:

    $for(author)$
    $if(author.name)$
    $author.name$$if(author.affiliation)$ ($author.affiliation$)$endif$
    $else$
    $author$
    $endif$
    $endfor$

    $if(abstract)$
    Abstract: $abstract$
    $endif$

Backslash escapes
-----------------

**Extension: `all_symbols_escapable`**

Except inside a code block or inline code, any punctuation or space
character preceded by a backslash will be treated literally, even if it
would normally indicate formatting.  Thus, for example, if one writes

    *\*hello\**

one will get

    <em>*hello*</em>

instead of

    <strong>hello</strong>

This rule is easier to remember than standard markdown's rule,
which allows only the following characters to be backslash-escaped:

    \`*_{}[]()>#+-.!

(However, if the `markdown_strict` format is used, the standard markdown rule
will be used.)

A backslash-escaped space is parsed as a nonbreaking space.  It will
appear in TeX output as `~` and in HTML and XML as `\&#160;` or
`\&nbsp;`.

A backslash-escaped newline (i.e. a backslash occurring at the end of
a line) is parsed as a hard line break.  It will appear in TeX output as
`\\` and in HTML as `<br />`.  This is a nice alternative to
markdown's "invisible" way of indicating hard line breaks using
two trailing spaces on a line.

Backslash escapes do not work in verbatim contexts.

Smart punctuation
-----------------

**Extension**

If the `--smart` option is specified, pandoc will produce typographically
correct output, converting straight quotes to curly quotes, `---` to
em-dashes, `--` to en-dashes, and `...` to ellipses. Nonbreaking spaces
are inserted after certain abbreviations, such as "Mr."

Note:  if your LaTeX template uses the `csquotes` package, pandoc will
detect automatically this and use `\enquote{...}` for quoted text.

Inline formatting
-----------------

### Emphasis ###

To *emphasize* some text, surround it with `*`s or `_`, like this:

    This text is _emphasized with underscores_, and this
    is *emphasized with asterisks*.

Double `*` or `_` produces **strong emphasis**:

    This is **strong emphasis** and __with underscores__.

A `*` or `_` character surrounded by spaces, or backslash-escaped,
will not trigger emphasis:

    This is * not emphasized *, and \*neither is this\*.

**Extension: `intraword_underscores`**

Because `_` is sometimes used inside words and identifiers,
pandoc does not interpret a `_` surrounded by alphanumeric
characters as an emphasis marker.  If you want to emphasize
just part of a word, use `*`:

    feas*ible*, not feas*able*.


### Strikeout ###

**Extension:  `strikeout`**

To strikeout a section of text with a horizontal line, begin and end it
with `~~`. Thus, for example,

    This ~~is deleted text.~~


### Superscripts and subscripts ###

**Extension: `superscript`, `subscript`**

Superscripts may be written by surrounding the superscripted text by `^`
characters; subscripts may be written by surrounding the subscripted
text by `~` characters.  Thus, for example,

    H~2~O is a liquid.  2^10^ is 1024.

If the superscripted or subscripted text contains spaces, these spaces
must be escaped with backslashes.  (This is to prevent accidental
superscripting and subscripting through the ordinary use of `~` and `^`.)
Thus, if you want the letter P with 'a cat' in subscripts, use
`P~a\ cat~`, not `P~a cat~`.


### Verbatim ###

To make a short span of text verbatim, put it inside backticks:

    What is the difference between `>>=` and `>>`?

If the verbatim text includes a backtick, use double backticks:

    Here is a literal backtick `` ` ``.

(The spaces after the opening backticks and before the closing
backticks will be ignored.)

The general rule is that a verbatim span starts with a string
of consecutive backticks (optionally followed by a space)
and ends with a string of the same number of backticks (optionally
preceded by a space).

Note that backslash-escapes (and other markdown constructs) do not
work in verbatim contexts:

    This is a backslash followed by an asterisk: `\*`.

**Extension: `inline_code_attributes`**

Attributes can be attached to verbatim text, just as with
[fenced code blocks](#fenced-code-blocks):

    `<$>`{.haskell}

Math
----

**Extension: `tex_math_dollars`**

Anything between two `$` characters will be treated as TeX math.  The
opening `$` must have a character immediately to its right, while the
closing `$` must have a character immediately to its left.  Thus,
`$20,000 and $30,000` won't parse as math.  If for some reason
you need to enclose text in literal `$` characters, backslash-escape
them and they won't be treated as math delimiters.

TeX math will be printed in all output formats. How it is rendered
depends on the output format:

Markdown, LaTeX, Org-Mode, ConTeXt
  ~ It will appear verbatim between `$` characters.

reStructuredText
  ~ It will be rendered using an interpreted text role `:math:`, as described
    [here](http://www.american.edu/econ/itex2mml/mathhack.rst).

AsciiDoc
  ~ It will be rendered as `latexmath:[...]`.

Texinfo
  ~ It will be rendered inside a `@math` command.

groff man
  ~ It will be rendered verbatim without `$`'s.

MediaWiki
  ~ It will be rendered inside `<math>` tags.

Textile
  ~ It will be rendered inside `<span class="math">` tags.

RTF, OpenDocument, ODT
  ~ It will be rendered, if possible, using unicode characters,
    and will otherwise appear verbatim.

Docbook
  ~ If the `--mathml` flag is used, it will be rendered using mathml
    in an `inlineequation` or `informalequation` tag.  Otherwise it
    will be rendered, if possible, using unicode characters.

Docx
  ~ It will be rendered using OMML math markup.

FictionBook2
  ~ If the `--webtex` option is used, formulas are rendered as images
    using Google Charts or other compatible web service, downloaded
    and embedded in the e-book. Otherwise, they will appear verbatim.

HTML, Slidy, DZSlides, S5, EPUB
  ~ The way math is rendered in HTML will depend on the
    command-line options selected:

    1.  The default is to render TeX math as far as possible using unicode
        characters, as with RTF, DocBook, and OpenDocument output. Formulas
        are put inside a `span` with `class="math"`, so that they may be
        styled differently from the surrounding text if needed.

    2.  If the `--latexmathml` option is used, TeX math will be displayed
        between `$` or `$$` characters and put in `<span>` tags with class `LaTeX`.
        The [LaTeXMathML] script will be used to render it as formulas.
        (This trick does not work in all browsers, but it works in Firefox.
        In browsers that do not support LaTeXMathML, TeX math will appear
        verbatim between `$` characters.)

    3.  If the `--jsmath` option is used, TeX math will be put inside
        `<span>` tags (for inline math) or `<div>` tags (for display math)
        with class `math`.  The [jsMath] script will be used to render
        it.

    4.  If the `--mimetex` option is used, the [mimeTeX] CGI script will
        be called to generate images for each TeX formula. This should
        work in all browsers. The `--mimetex` option takes an optional URL
        as argument. If no URL is specified, it will be assumed that the
        mimeTeX CGI script is at `/cgi-bin/mimetex.cgi`.

    5.  If the `--gladtex` option is used, TeX formulas will be enclosed
        in `<eq>` tags in the HTML output.  The resulting `htex` file may then
        be processed by [gladTeX], which will produce image files for each
        formula and an `html` file with links to these images.  So, the
        procedure is:

            pandoc -s --gladtex myfile.txt -o myfile.htex
            gladtex -d myfile-images myfile.htex
            # produces myfile.html and images in myfile-images

    6.  If the `--webtex` option is used, TeX formulas will be converted
        to `<img>` tags that link to an external script that converts
        formulas to images. The formula will be URL-encoded and concatenated
        with the URL provided. If no URL is specified, the Google Chart
        API will be used (`http://chart.apis.google.com/chart?cht=tx&chl=`).

    7.  If the `--mathjax` option is used, TeX math will be displayed
        between `\(...\)` (for inline math) or `\[...\]` (for display
        math) and put in `<span>` tags with class `math`.
        The [MathJax] script will be used to render it as formulas.

Raw HTML
--------

**Extension: `raw_html`**

Markdown allows you to insert raw HTML (or DocBook) anywhere in a document
(except verbatim contexts, where `<`, `>`, and `&` are interpreted
literally).  (Techncially this is not an extension, since standard
markdown allows it, but it has been made an extension so that it can
be disabled if desired.)

The raw HTML is passed through unchanged in HTML, S5, Slidy, Slideous,
DZSlides, EPUB, Markdown, and Textile output, and suppressed in other
formats.

**Extension: `markdown_in_html_blocks`**

Standard markdown allows you to include HTML "blocks":  blocks
of HTML between balanced tags that are separated from the surrounding text
with blank lines, and start and end at the left margin.  Within
these blocks, everything is interpreted as HTML, not markdown;
so (for example), `*` does not signify emphasis.

Pandoc behaves this way when the `markdown_strict` format is used; but
by default, pandoc interprets material between HTML block tags as markdown.
Thus, for example, Pandoc will turn

    <table>
    	<tr>
    		<td>*one*</td>
    		<td>[a link](http://google.com)</td>
    	</tr>
    </table>

into

    <table>
    	<tr>
    		<td><em>one</em></td>
    		<td><a href="http://google.com">a link</a></td>
    	</tr>
    </table>

whereas `Markdown.pl` will preserve it as is.

There is one exception to this rule:  text between `<script>` and
`<style>` tags is not interpreted as markdown.

This departure from standard markdown should make it easier to mix
markdown with HTML block elements.  For example, one can surround
a block of markdown text with `<div>` tags without preventing it
from being interpreted as markdown.

Raw TeX
-------

**Extension: `raw_tex`**

In addition to raw HTML, pandoc allows raw LaTeX, TeX, and ConTeXt to be
included in a document. Inline TeX commands will be preserved and passed
unchanged to the LaTeX and ConTeXt writers. Thus, for example, you can use
LaTeX to include BibTeX citations:

    This result was proved in \cite{jones.1967}.

Note that in LaTeX environments, like

    \begin{tabular}{|l|l|}\hline
    Age & Frequency \\ \hline
    18--25  & 15 \\
    26--35  & 33 \\
    36--45  & 22 \\ \hline
    \end{tabular}

the material between the begin and end tags will be interpreted as raw
LaTeX, not as markdown.

Inline LaTeX is ignored in output formats other than Markdown, LaTeX,
and ConTeXt.

LaTeX macros
------------

**Extension: `latex_macros`**

For output formats other than LaTeX, pandoc will parse LaTeX `\newcommand` and
`\renewcommand` definitions and apply the resulting macros to all LaTeX
math.  So, for example, the following will work in all output formats,
not just LaTeX:

    \newcommand{\tuple}[1]{\langle #1 \rangle}

    $\tuple{a, b, c}$

In LaTeX output, the `\newcommand` definition will simply be passed
unchanged to the output.


リンク [links]
-----

Markdown allows links to be specified in several ways.

### Automatic links ###

If you enclose a URL or email address in pointy brackets, it
will become a link:

    <http://google.com>
    <sam@green.eggs.ham>

### Inline links ###

An inline link consists of the link text in square brackets,
followed by the URL in parentheses. (Optionally, the URL can
be followed by a link title, in quotes.)

    This is an [inline link](/url), and here's [one with
    a title](http://fsf.org "click here for a good time!").

There can be no space between the bracketed part and the parenthesized part.
The link text can contain formatting (such as emphasis), but the title cannot.


### Reference links ###

An *explicit* reference link has two parts, the link itself and the link
definition, which may occur elsewhere in the document (either
before or after the link).

The link consists of link text in square brackets, followed by a label in
square brackets. (There can be space between the two.) The link definition
consists of the bracketed label, followed by a colon and a space, followed by
the URL, and optionally (after a space) a link title either in quotes or in
parentheses.

Here are some examples:

    [my label 1]: /foo/bar.html  "My title, optional"
    [my label 2]: /foo
    [my label 3]: http://fsf.org (The free software foundation)
    [my label 4]: /bar#special  'A title in single quotes'

The URL may optionally be surrounded by angle brackets:

    [my label 5]: <http://foo.bar.baz>

The title may go on the next line:

    [my label 3]: http://fsf.org
      "The free software foundation"

Note that link labels are not case sensitive.  So, this will work:

    Here is [my link][FOO]

    [Foo]: /bar/baz

In an *implicit* reference link, the second pair of brackets is
empty, or omitted entirely:

    See [my website][], or [my website].

    [my website]: http://foo.bar.baz

Note:  In `Markdown.pl` and most other markdown implementations,
reference link definitions cannot occur in nested constructions
such as list items or block quotes.  Pandoc lifts this arbitrary
seeming restriction.  So the following is fine in pandoc, though
not in most other implementations:

    > My block [quote].
    >
    > [quote]: /foo

### Internal links

To link to another section of the same document, use the automatically
generated identifier (see [Header identifiers in HTML, LaTeX, and
ConTeXt](#header-identifiers-in-html-latex-and-context), below).
For example:

    See the [Introduction](#introduction).

or

    See the [Introduction].

    [Introduction]: #introduction

Internal links are currently supported for HTML formats (including
HTML slide shows and EPUB), LaTeX, and ConTeXt.

Images
------

A link immediately preceded by a `!` will be treated as an image.
The link text will be used as the image's alt text:

    ![la lune](lalune.jpg "Voyage to the moon")

    ![movie reel]

    [movie reel]: movie.gif

### Pictures with captions ###

**Extension: `implicit_figures`**

An image occurring by itself in a paragraph will be rendered as
a figure with a caption.[^5] (In LaTeX, a figure environment will be
used; in HTML, the image will be placed in a `div` with class
`figure`, together with a caption in a `p` with class `caption`.)
The image's alt text will be used as the caption.

    ![This is the caption](/url/of/image.png)

[^5]: This feature is not yet implemented for RTF, OpenDocument, or
    ODT. In those formats, you'll just get an image in a paragraph by
    itself, with no caption.

If you just want a regular inline image, just make sure it is not
the only thing in the paragraph. One way to do this is to insert a
nonbreaking space after the image:

    ![This image won't be a figure](/url/of/image.png)\


Footnotes
---------

**Extension: `footnotes`**

Pandoc's markdown allows footnotes, using the following syntax:

    Here is a footnote reference,[^1] and another.[^longnote]

    [^1]: Here is the footnote.

    [^longnote]: Here's one with multiple blocks.

        Subsequent paragraphs are indented to show that they
    belong to the previous footnote.

            { some.code }

        The whole paragraph can be indented, or just the first
        line.  In this way, multi-paragraph footnotes work like
        multi-paragraph list items.

    This paragraph won't be part of the note, because it
    isn't indented.

The identifiers in footnote references may not contain spaces, tabs,
or newlines.  These identifiers are used only to correlate the
footnote reference with the note itself; in the output, footnotes
will be numbered sequentially.

The footnotes themselves need not be placed at the end of the
document.  They may appear anywhere except inside other block elements
(lists, block quotes, tables, etc.).

**Extension: `inline_notes`**

Inline footnotes are also allowed (though, unlike regular notes,
they cannot contain multiple paragraphs).  The syntax is as follows:

    Here is an inline note.^[Inlines notes are easier to write, since
    you don't have to pick an identifier and move down to type the
    note.]

Inline and regular footnotes may be mixed freely.


文献の引用 [citations]
--------

**Extension: `citations`**

Using an external filter, `pandoc-citeproc`, pandoc can automatically generate
citations and a bibliography in a number of styles.  Basic usage is

    pandoc --filter pandoc-citeproc myinput.txt

In order to use this feature, you will need to specify a bibliography file
using the `bibliography` metadata field in a YAML metadata section.
The bibliography may have any of these formats:

  Format            File extension
  ------------      --------------
  MODS              .mods
  BibLaTeX          .bib
  BibTeX            .bibtex
  RIS               .ris
  EndNote           .enl
  EndNote XML       .xml
  ISI               .wos
  MEDLINE           .medline
  Copac             .copac
  JSON citeproc     .json

Note that `.bib` can generally be used with both BibTeX and BibLaTeX
files, but you can use `.bibtex` to force BibTeX.

Alternatively you can use a `references` field in the document's YAML
metadata.  This should include an array of YAML-encoded references,
for example:

    ---
    references:
    - id: fenner2012a
      title: One-click science marketing
      author:
      - family: Fenner
        given: Martin
      container-title: Nature Materials
      volume: 11
      URL: 'http://dx.doi.org/10.1038/nmat3283'
      DOI: 10.1038/nmat3283
      issue: 4
      publisher: Nature Publishing Group
      page: 261-263
      type: article-journal
      issued:
        year: 2012
        month: 3
    ...

(The program `mods2yaml`, which comes with `pandoc-citeproc`, can help produce
these from a MODS reference collection.)

By default, `pandoc-citeproc` will use a Chicago author-date format for
citations and references.  To use another style, you will need to specify
a [CSL] 1.0 style file in the `csl` metadata field.  A primer on creating and
modifying CSL styles can be found at
<http://citationstyles.org/downloads/primer.html>.  A repository of CSL styles
can be found at <https://github.com/citation-style-language/styles>.  See also
<http://zotero.org/styles> for easy browsing.

Citations go inside square brackets and are separated by semicolons.
Each citation must have a key, composed of '@' + the citation
identifier from the database, and may optionally have a prefix,
a locator, and a suffix.  Here are some examples:

    Blah blah [see @doe99, pp. 33-35; also @smith04, ch. 1].

    Blah blah [@doe99, pp. 33-35, 38-39 and *passim*].

    Blah blah [@smith04; @doe99].

A minus sign (`-`) before the `@` will suppress mention of
the author in the citation.  This can be useful when the
author is already mentioned in the text:

    Smith says blah [-@smith04].

You can also write an in-text citation, as follows:

    @smith04 says blah.

    @smith04 [p. 33] says blah.

If the style calls for a list of works cited, it will be placed
at the end of the document.  Normally, you will want to end your
document with an appropriate header:

    last paragraph...

    # References

The bibliography will be inserted after this header.

Non-pandoc extensions
---------------------

The following markdown syntax extensions are not enabled by default
in pandoc, but may be enabled by adding `+EXTENSION` to the format
name, where `EXTENSION` is the name of the extension.  Thus, for
example, `markdown+hard_line_breaks` is markdown with hard line breaks.

**Extension:  `lists_without_preceding_blankline`**\
Allow a list to occur right after a paragraph, with no intervening
blank space.

**Extension:  `hard_line_breaks`**\
Causes all newlines within a paragraph to be interpreted as hard line
breaks instead of spaces.

**Extension:  `ignore_line_breaks`**\
Causes newlines within a paragraph to be ignored, rather than being
treated as spaces or as hard line breaks.  This option is intended for
use with East Asian languages where spaces are not used between words,
but text is divided into lines for readability.

**Extension: `tex_math_single_backslash`**\
Causes anything between `\(` and `\)` to be interpreted as inline
TeX math, and anything between `\[` and `\]` to be interpreted
as display TeX math.  Note: a drawback of this extension is that
it precludes escaping `(` and `[`.

**Extension: `tex_math_double_backslash`**\
Causes anything between `\\(` and `\\)` to be interpreted as inline
TeX math, and anything between `\\[` and `\\]` to be interpreted
as display TeX math.

**Extension: `markdown_attribute`**\
By default, pandoc interprets material inside block-level tags as markdown.
This extension changes the behavior so that markdown is only parsed
inside block-level tags if the tags have the attribute `markdown=1`.

**Extension: `mmd_title_block`**\
Enables a [MultiMarkdown] style title block at the top of
the document, for example:

    Title:   My title
    Author:  John Doe
    Date:    September 1, 2008
    Comment: This is a sample mmd title block, with
             a field spanning multiple lines.

See the MultiMarkdown documentation for details. Note that only title,
author, and date are recognized; other fields are simply ignored by
pandoc. If `pandoc_title_block` or `yaml_metadata_block` is enabled,
it will take precedence over `mmd_title_block`.

  [MultiMarkdown]: http://fletcherpenney.net/multimarkdown/

**Extension: `abbreviations`**\
Parses PHP Markdown Extra abbreviation keys, like

    *[HTML]: Hyper Text Markup Language

Note that the pandoc document model does not support
abbreviations, so if this extension is enabled, abbreviation keys are
simply skipped (as opposed to being parsed as paragraphs).

**Extension: `autolink_bare_uris`**\
Makes all absolute URIs into links, even when not surrounded by
pointy braces `<...>`.

**Extension: `ascii_identifiers`**\
Causes the identifiers produced by `auto_identifiers` to be pure ASCII.
Accents are stripped off of accented latin letters, and non-latin
letters are omitted.

**Extension: `link_attributes`**\
Parses multimarkdown style key-value attributes on link and image references.
Note that pandoc's internal document model provides nowhere to put
these, so they are presently just ignored.

**Extension: `mmd_header_identifiers`**\
Parses multimarkdown style header identifiers (in square brackets,
after the header but before any trailing `#`s in an ATX header).

Markdown variants
-----------------

In addition to pandoc's extended markdown, the following markdown
variants are supported:

`markdown_phpextra` (PHP Markdown Extra)
:   `footnotes`, `pipe_tables`, `raw_html`, `markdown_attribute`,
    `fenced_code_blocks`, `definition_lists`, `intraword_underscores`,
    `header_attributes`, `abbreviations`.

`markdown_github` (Github-flavored Markdown)
:   `pipe_tables`, `raw_html`, `tex_math_single_backslash`,
    `fenced_code_blocks`, `fenced_code_attributes`, `auto_identifiers`,
    `ascii_identifiers`, `backtick_code_blocks`, `autolink_bare_uris`,
    `intraword_underscores`, `strikeout`, `hard_line_breaks`

`markdown_mmd` (MultiMarkdown)
:   `pipe_tables` `raw_html`, `markdown_attribute`, `link_attributes`,
    `raw_tex`, `tex_math_double_backslash`, `intraword_underscores`,
    `mmd_title_block`, `footnotes`, `definition_lists`,
    `all_symbols_escapable`, `implicit_header_references`,
    `auto_identifiers`, `mmd_header_identifiers`

`markdown_strict` (Markdown.pl)
:   `raw_html`

Extensions with formats other than markdown
-------------------------------------------

Some of the extensions discussed above can be used with formats
other than markdown:

* `auto_identifiers` can be used with `latex`, `rst`, `mediawiki`,
  and `textile` input (and is used by default).

* `tex_math_dollars`, `tex_math_single_backslash`, and
  `tex_math_double_backslash` can be used with `html` input.
  (This is handy for reading web pages formatted using MathJax,
  for example.)

Producing slide shows with Pandoc
=================================

You can use Pandoc to produce an HTML + javascript slide presentation
that can be viewed via a web browser.  There are five ways to do this,
using [S5], [DZSlides], [Slidy], [Slideous], or [reveal.js].
You can also produce a PDF slide show using LaTeX [beamer].

Here's the markdown source for a simple slide show, `habits.txt`:

    % Habits
    % John Doe
    % March 22, 2005

    # In the morning

    ## Getting up

    - Turn off alarm
    - Get out of bed

    ## Breakfast

    - Eat eggs
    - Drink coffee

    # In the evening

    ## Dinner

    - Eat spaghetti
    - Drink wine

    ------------------

    ![picture of spaghetti](images/spaghetti.jpg)

    ## Going to sleep

    - Get in bed
    - Count sheep

To produce an HTML/javascript slide show, simply type

    pandoc -t FORMAT -s habits.txt -o habits.html

where `FORMAT` is either `s5`, `slidy`, `slideous`, `dzslides`, or `revealjs`.

For Slidy, Slideous, reveal.js, and S5, the file produced by pandoc with the
`-s/--standalone` option embeds a link to javascripts and CSS files, which are
assumed to be available at the relative path `s5/default` (for S5), `slideous`
(for Slideous), `reveal.js` (for reveal.js), or at the Slidy website at
`w3.org` (for Slidy).  (These paths can be changed by setting the `slidy-url`,
`slideous-url`, `revealjs-url`, or `s5-url` variables; see `--variable`,
above.) For DZSlides, the (relatively short) javascript and css are included in
the file by default.

With all HTML slide formats, the `--self-contained` option can be used to
produce a single file that contains all of the data necessary to display the
slide show, including linked scripts, stylesheets, images, and videos.

To produce a PDF slide show using beamer, type

    pandoc -t beamer habits.txt -o habits.pdf

Note that a reveal.js slide show can also be converted to a PDF
by printing it to a file from the browser.

スライドショーの構造を作る    [structuring-the-slide-show]
-----------------------

By default, the *slide level* is the highest header level in
the hierarchy that is followed immediately by content, and not another
header, somewhere in the document. In the example above, level 1 headers
are always followed by level 2 headers, which are followed by content,
so 2 is the slide level.  This default can be overridden using
the `--slide-level` option.

The document is carved up into slides according to the following
rules:

  * A horizontal rule always starts a new slide.

  * A header at the slide level always starts a new slide.

  * Headers *below* the slide level in the hierarchy create
    headers *within* a slide.

  * Headers *above* the slide level in the hierarchy create
    "title slides," which just contain the section title
    and help to break the slide show into sections.

  * A title page is constructed automatically from the document's title
    block, if present.  (In the case of beamer, this can be disabled
    by commenting out some lines in the default template.)

These rules are designed to support many different styles of slide show. If
you don't care about structuring your slides into sections and subsections,
you can just use level 1 headers for all each slide. (In that case, level 1
will be the slide level.) But you can also structure the slide show into
sections, as in the example above.

Note:  in reveal.js slide shows, if slide level is 2, a two-dimensional
layout will be produced, with level 1 headers building horizontally
and level 2 headers building vertically.  It is not recommended that
you use deeper nesting of section levels with reveal.js.

Incremental lists
-----------------

By default, these writers produces lists that display "all at once."
If you want your lists to display incrementally (one item at a time),
use the `-i` option. If you want a particular list to depart from the
default (that is, to display incrementally without the `-i` option and
all at once with the `-i` option), put it in a block quote:

    > - Eat spaghetti
    > - Drink wine

In this way incremental and nonincremental lists can be mixed in
a single document.

Inserting pauses
----------------

You can add "pauses" within a slide by including a paragraph containing
three dots, separated by spaces:

    # Slide with a pause

    content before the pause

    . . .

    content after the pause

Styling the slides
------------------

You can change the style of HTML slides by putting customized CSS files
in `$DATADIR/s5/default` (for S5), `$DATADIR/slidy` (for Slidy),
or `$DATADIR/slideous` (for Slideous),
where `$DATADIR` is the user data directory (see `--data-dir`, above).
The originals may be found in pandoc's system data directory (generally
`$CABALDIR/pandoc-VERSION/s5/default`). Pandoc will look there for any
files it does not find in the user data directory.

For dzslides, the CSS is included in the HTML file itself, and may
be modified there.

For reveal.js, themes can be used by setting the `theme` variable,
for example:

    -V theme=moon

Or you can specify a custom stylesheet using the `--css` option.

To style beamer slides, you can specify a beamer "theme" or "colortheme"
using the `-V` option:

    pandoc -t beamer habits.txt -V theme:Warsaw -o habits.pdf

Note that header attributes will turn into slide attributes
(on a `<div>` or `<section>`) in HTML slide formats, allowing you
to style individual slides.  In Beamer, the only header attribute
that affects slides is the `allowframebreaks` class, which sets the
`allowframebreaks` option, causing multiple slides to be created
if the content overfills the frame.  This is recommended especially for
bibliographies:

    # References {.allowframebreaks}

Speaker notes
-------------

reveal.js has good support for speaker notes.  You can add notes to your
markdown document thus:

    <div class="notes">
    This is my note.

    - It can contain markdown
    - like this list

    </div>

To show the notes window, press `s` while viewing the presentation.
Notes are not yet supported for other slide formats, but the notes
will not appear on the slides themselves.

EPUBメタデータ [epub-metadata]
=============

EPUB metadata may be specified using the `--epub-metadata` option, but
if the source document is markdown, it is better to use a YAML metadata
block.  Here is an example:

    ---
    title:
    - type: main
      text: My Book
    - type: subtitle
      text: An investigation of metadata
    creator:
    - role: author
      text: John Smith
    - role: editor
      text: Sarah Jones
    identifier:
    - scheme: DOI
      text: doi:10.234234.234/33
    publisher:  My Press
    rights:  (c) 2007 John Smith, CC BY-NC
    ...

The following fields are recognized:

`identifier`
  ~ Either a string value or an object with fields `text` and
    `scheme`.  Valid values for `scheme` are `ISBN-10`,
    `GTIN-13`, `UPC`, `ISMN-10`, `DOI`, `LCCN`, `GTIN-14`,
    `ISBN-13`, `Legal deposit number`, `URN`, `OCLC`,
    `ISMN-13`, `ISBN-A`, `JP`, `OLCC`.
`title`
  ~ Either a string value, or an object with fields `file-as` and
    `type`, or a list of such objects.  Valid values for `type` are
    `main`, `subtitle`, `short`, `collection`, `edition`, `extended`.
`creator`
  ~ Either a string value, or an object with fields `role`, `file-as`,
    and `text`, or a list of such objects.  Valid values for `role` are
    [marc relators](http://www.loc.gov/marc/relators/relaterm.html), but
    pandoc will attempt to translate the human-readable versions
    (like "author" and "editor") to the appropriate marc relators.
`contributor`
  ~ Same format as `creator`.
`date`
  ~ A string value in `YYYY-MM-DD` format.  (Only the year is necessary.)
    Pandoc will attempt to convert other common date formats.
`language`
  ~ A string value in [RFC5646] format.  Pandoc will default to the local
    language if nothing is specified.
`subject`
  ~ A string value or a list of such values.
`description`
  ~ A string value.
`type`
  ~ A string value.
`format`
  ~ A string value.
`relation`
  ~ A string value.
`coverage`
  ~ A string value.
`rights`
  ~ A string value.
`cover-image`
  ~ A string value (path to cover image).
`stylesheet`
  ~ A string value (path to CSS stylesheet).

Literate Haskellのサポート [literate-haskell-support]
========================

If you append `+lhs` (or `+literate_haskell`) to an appropriate input or output
format (`markdown`, `mardkown_strict`, `rst`, or `latex` for input or output;
`beamer`, `html` or `html5` for output only), pandoc will treat the document as
literate Haskell source. This means that

  - In markdown input, "bird track" sections will be parsed as Haskell
    code rather than block quotations.  Text between `\begin{code}`
    and `\end{code}` will also be treated as Haskell code.

  - In markdown output, code blocks with classes `haskell` and `literate`
    will be rendered using bird tracks, and block quotations will be
    indented one space, so they will not be treated as Haskell code.
    In addition, headers will be rendered setext-style (with underlines)
    rather than atx-style (with '#' characters). (This is because ghc
    treats '#' characters in column 1 as introducing line numbers.)

  - In restructured text input, "bird track" sections will be parsed
    as Haskell code.

  - In restructured text output, code blocks with class `haskell` will
    be rendered using bird tracks.

  - In LaTeX input, text in `code` environments will be parsed as
    Haskell code.

  - In LaTeX output, code blocks with class `haskell` will be rendered
    inside `code` environments.

  - In HTML output, code blocks with class `haskell` will be rendered
    with class `literatehaskell` and bird tracks.

Examples:

    pandoc -f markdown+lhs -t html

reads literate Haskell source formatted with markdown conventions and writes
ordinary HTML (without bird tracks).

    pandoc -f markdown+lhs -t html+lhs

writes HTML with the Haskell code in bird tracks, so it can be copied
and pasted as literate Haskell source.

カスタムWriter [custom-writers]
==============

Pandoc can be extended with custom writers written in [lua].  (Pandoc
includes a lua interpreter, so lua need not be installed separately.)

To use a custom writer, simply specify the path to the lua script
in place of the output format. For example:

    pandoc -t data/sample.lua

Creating a custom writer requires writing a lua function for each
possible element in a pandoc document.  To get a documented example
which you can modify according to your needs, do

    pandoc --print-default-data-file sample.lua

Authors
=======

© 2006-2013 John MacFarlane (jgm at berkeley dot edu). Released under the
[GPL], version 2 or greater.  This software carries no warranty of
any kind.  (See COPYRIGHT for full copyright and warranty notices.)
Other contributors include Recai Oktaş, Paulo Tanimoto, Peter Wang,
Andrea Rossato, Eric Kow, infinity0x, Luke Plant, shreevatsa.public,
Puneeth Chaganti, Paul Rivier, rodja.trappe, Bradley Kuhn, thsutton,
Nathan Gass, Jonathan Daugherty, Jérémy Bobbio, Justin Bogner, qerub,
Christopher Sawicki, Kelsey Hightower, Masayoshi Takahashi, Antoine
Latter, Ralf Stephan, Eric Seidel, B. Scott Michel, Gavin Beatty,
Sergey Astanin, Arlo O'Keeffe, Denis Laxalde, Brent Yorgey, David Lazar,
Jamie F. Olson.

[markdown]: http://daringfireball.net/projects/markdown/
[reStructuredText]: http://docutils.sourceforge.net/docs/ref/rst/introduction.html
[S5]: http://meyerweb.com/eric/tools/s5/
[Slidy]: http://www.w3.org/Talks/Tools/Slidy/
[Slideous]: http://goessner.net/articles/slideous/
[HTML]:  http://www.w3.org/TR/html40/
[HTML 5]:  http://www.w3.org/TR/html5/
[XHTML]:  http://www.w3.org/TR/xhtml1/
[LaTeX]: http://www.latex-project.org/
[beamer]: http://www.tex.ac.uk/CTAN/macros/latex/contrib/beamer
[ConTeXt]: http://www.pragma-ade.nl/
[RTF]:  http://en.wikipedia.org/wiki/Rich_Text_Format
[DocBook]:  http://www.docbook.org/
[OPML]: http://dev.opml.org/spec2.html
[OpenDocument]: http://opendocument.xml.org/
[ODT]: http://en.wikipedia.org/wiki/OpenDocument
[Textile]: http://redcloth.org/textile
[MediaWiki markup]: http://www.mediawiki.org/wiki/Help:Formatting
[Haddock markup]: http://www.haskell.org/haddock/doc/html/ch03s08.html
[groff man]: http://developer.apple.com/DOCUMENTATION/Darwin/Reference/ManPages/man7/groff_man.7.html
[Haskell]:  http://www.haskell.org/
[GNU Texinfo]: http://www.gnu.org/software/texinfo/
[Emacs Org-Mode]: http://orgmode.org
[AsciiDoc]: http://www.methods.co.nz/asciidoc/
[EPUB]: http://www.idpf.org/
[GPL]: http://www.gnu.org/copyleft/gpl.html "GNU General Public License"
[DZSlides]: http://paulrouget.com/dzslides/
[ISO 8601 format]: http://www.w3.org/TR/NOTE-datetime
[Word docx]: http://www.microsoft.com/interop/openup/openxml/default.aspx
[PDF]: http://www.adobe.com/pdf/
[reveal.js]: http://lab.hakim.se/reveal-js/
[FictionBook2]: http://www.fictionbook.org/index.php/Eng:XML_Schema_Fictionbook_2.1
[lua]: http://www.lua.org
[marc relators]: http://www.loc.gov/marc/relators/relaterm.html
[RFC5646]: http://tools.ietf.org/html/rfc5646
