# enkeys: if the keyboard is on Arabic, what you type on the command line still comes out in English,
# as if the layout were US (ش→a, س→s ...). Alt+A lets you type Arabic for the current line only.
# Needs ble.sh. Turn off with TK_DISABLE=(enkeys). Editors and TUIs (micro, fzf, mc) are not affected.
# Map: Windows "Arabic (101)" layout. Shifted keys that already give ASCII there ([ ] : " / < > ~ { })
# can't be remapped without breaking English, so Shift+D F L ; ' Z C V , . stay as Arabic gives them.
[[ ${BLE_VERSION-} ]] || return 0

_tk_ar=0   # 1 = Arabic passthrough for this line (Alt+A)
# tk-key <english> <arabic>: insert the English char, or the Arabic one while passthrough is on
function ble/widget/tk-key { if ((_tk_ar)); then ble/widget/insert-string "$2"; else ble/widget/insert-string "$1"; fi; }
function ble/widget/tk-arabic-toggle {
  _tk_ar=$((1 - _tk_ar))
  if ((_tk_ar)); then ble/edit/info/show text 'Arabic typing for this line (Alt+A to go back)'
  else ble/edit/info/show text 'English typing'; fi
}
_tk_ar_reset() { _tk_ar=0; }
blehook PRECMD+=_tk_ar_reset   # every new command line starts in English again

_tk_map() { local a=$1 e=$2; ble-bind -m emacs -f "$a" "tk-key $(printf %q "$e") $(printf %q "${a// /}")"; }
# unshifted letters and punctuation keys
for _p in 'ذ`' 'ضq' 'صw' 'ثe' 'قr' 'فt' 'غy' 'عu' 'هi' 'خo' 'حp' 'ج[' 'د]' \
          'شa' 'سs' 'يd' 'بf' 'لg' 'اh' 'تj' 'نk' 'مl' 'ك;' "ط'" \
          'ئz' 'ءx' 'ؤc' 'رv' 'ىn' 'ةm' 'و,' 'ز.' 'ظ/'; do _tk_map "${_p:0:1}" "${_p:1}"; done
# shifted: diacritics and Arabic punctuation become the shifted English key
# shellcheck disable=SC1112  # ‘ and ’ are real keys on the Arabic layout (Shift+U, Shift+M), not typos
for _p in 'ّ~' 'َQ' 'ًW' 'ُE' 'ٌR' 'إY' '‘U' '÷I' '×O' '؛P' 'ِA' 'ٍS' 'أH' 'ـJ' '،K' 'ْX' 'آN' '’M' '؟?'; do
  _tk_map "${_p:0:1}" "${_p:1}"; done
unset _p
# Ligature keys send two characters (ل + alef). Shift+T, Shift+G and Shift+B are unambiguous enough:
_tk_map 'ل إ' T; _tk_map 'ل أ' G; _tk_map 'ل آ' B
# The B key sends ل then ا, exactly what G then H sends. b is far more common on a command line
# (bash, bat, branch, ~/bin), so "لا" types b; the price is `gh` typed on the Arabic layout becomes b.
_tk_map 'ل ا' b

ble-bind -m emacs -f M-a tk-arabic-toggle
ble-bind -m emacs -f 'M-ش' tk-arabic-toggle   # Alt+A pressed while the layout is Arabic
