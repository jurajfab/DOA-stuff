CTRL + Space - meta klávesa (ďalej označené ako META)
META c - nové okno
META 0 až META 9 - rýchle prepínanie sa medzi oknami
META n - prepne na nasledujúce okno v poradí
META p - prepne na predchádzajúce okno v poradí
META " - rozdelí aktuálne okno na polovicu horizontálne
META % - rozdelí aktuálne okno na polovicu vertikálne
META ? - zobrazí pomocníka so zoznamom klávesových skratiek
META x - ukončí aktuálne okno
META d - odpojí aktuálneho klienta

Ak sa chceme opätovne pripojiť ku odpojenému klientovi, použijeme na to príkaz:

$ tmux attach

Ak máme viacero odpojených sedení, zobrazíme si ich príkazom:

$ tmux ls

A ku konkrétnemu sedeniu sa pripojíme príkazom

$ tmux attach -t X