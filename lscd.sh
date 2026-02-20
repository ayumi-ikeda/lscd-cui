#!/bin/bash

# バージョン情報
VERSION="0.0.0"

# ヘルプ表示関数
show_help() {
    echo "Usage: lscd [ OPTION ]"
    echo ""
    echo "  -h, --help        使い方を表示して終了する"
    echo "  -v, --version     バージョン情報を表示して終了する"
    echo "  [ls OPTIONS]      lsコマンドのオプション（-aなど）を継承します"
    exit 0
}

# 引数処理
LS_OPTS=""
for arg in "$@"; do
    case $arg in
        -h|--help) show_help ;;
        -v|--version) echo "lscd version $VERSION"; exit 0 ;;
        *) LS_OPTS+="$arg " ;;
    esac
done

# 1. ディレクトリリストの取得（ファイルを除外し、名前のみ抽出）
# ls -d でディレクトリのみを対象とし、改行区切りで取得
dir_list=$(ls -dF $LS_OPTS 2>/dev/null | grep '/$' | sed 's/\/$//')

# 2. ディレクトリが存在しない場合の処理
if [ -z "$dir_list" ]; then
    whiptail --title "Error" --msgbox "ディレクトリがありません" 10 40
    exit 1
fi

# 3. whiptail用のメニュー作成 (tag item のペアを作る)
menu_items=()
while read -r line; do
    menu_items+=("$line" "")
done <<< "$dir_list"

# 4. メニュー表示
SELECTED_DIR=$(whiptail --title "lscd - Directory Changer" \
    --menu "移動先のディレクトリを選択してください" 20 60 12 \
    "${menu_items[@]}" \
    3>&1 1>&2 2>&3)

# キャンセルされた場合は終了
if [ -z "$SELECTED_DIR" ]; then
    exit 0
fi

# 5. シェルの判別と起動
# 親プロセス(自分)を起動したシェルを特定（特定できない場合はbash）
PARENT_SHELL=$(ps -p $PPID -o comm= | sed 's/-//')
[ -z "$PARENT_SHELL" ] && PARENT_SHELL="bash"

# プロンプトの設定（黄色で [lscd] を追加）
# \e[1;33m = 黄色太字, \e[0m = リセット
export PS1="\[\e[1;33m\][lscd]\[\e[0m\] $PS1"

echo "--------------------------------------------------"
echo "移動先: $SELECTED_DIR"
echo "終了して元の場所に戻るには 'Ctrl+D' または 'exit' を入力してください"
echo "--------------------------------------------------"

# 指定ディレクトリへ移動してサブシェルを起動
cd "$SELECTED_DIR" && exec $PARENT_SHELL --login