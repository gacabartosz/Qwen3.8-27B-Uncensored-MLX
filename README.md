# Qwen3.8-27B-Uncensored-MLX

Lustro repozytorium [onurburak9/Qwen3.8-27B-Uncensored-MLX](https://github.com/onurburak9/Qwen3.8-27B-Uncensored-MLX)
z gotowa instrukcja instalacji na Macu z Apple Silicon.

Model to wersja `Qwen/Qwen3.8-27B` z usunietymi odmowami (abliteration), skwantyzowana do
formatu MLX w czterech wariantach: 2, 4, 6 i 8 bit. Obsluguje tekst i obrazy.

Oryginalny opis modelu (po angielsku, z wynikami testow i szczegolami architektury):
[README.en.md](README.en.md).

> **Uwaga.** Model nie ma zabezpieczen: wykona tez szkodliwe polecenia, ktore oryginalny Qwen
> by odrzucil. Przeznaczony do badan (red-teaming, interpretowalnosc, testy odpornosci).
> Odpowiedzialnosc za uzycie i wygenerowane tresci ponosi uzytkownik. Szczegoly w
> [README.en.md](README.en.md), sekcja *Disclaimer & risks*.

## Co jest w repo

Struktura katalogow jest taka sama jak w oryginale: `2-bit/`, `4-bit/`, `6-bit/`, `8-bit/`
z konfiguracja, szablonem czatu i slownikiem tokenizera.

Samych wag (`*.safetensors`, razem ok. 73 GB) nie ma w gicie, bo GitHub nie przyjmuje tak
duzych plikow. Skrypt `install-mac.sh` pobiera je z Hugging Face
([orcarouter/Qwen3.8-27B-Uncensored-MLX](https://huggingface.co/orcarouter/Qwen3.8-27B-Uncensored-MLX))
prosto do wlasciwego katalogu.

## Instalacja na Mac

### Wymagania

- Mac z Apple Silicon (M1 lub nowszy). Intel nie jest obslugiwany.
- macOS 14 lub nowszy.
- Python 3.10 do 3.13 albo [uv](https://docs.astral.sh/uv/). Najprosciej: `brew install uv`.
- Wolne miejsce na dysku i RAM zgodnie z tabela:

| Wariant | Rozmiar | Min. RAM | Jakosc |
|---|---|---|---|
| `8-bit` | ok. 27,5 GB | 32 GB | prawie bez strat |
| `6-bit` | ok. 22 GB | 24 do 32 GB | bardzo dobra |
| `4-bit` | ok. 15 GB | 24 GB | dobra, **zalecany** |
| `2-bit` | ok. 8,7 GB | 16 GB | mocno zdegradowana, tylko archiwum |

### Trzy kroki

```bash
git clone https://github.com/gacabartosz/Qwen3.8-27B-Uncensored-MLX.git
cd Qwen3.8-27B-Uncensored-MLX
./install-mac.sh 4-bit
```

Skrypt:

1. sprawdza, czy to Apple Silicon i czy wystarczy RAM dla wybranego wariantu,
2. tworzy srodowisko `.venv` (przez `uv` albo `python3 -m venv`),
3. instaluje `mlx-vlm` i `huggingface_hub[cli]`,
4. pobiera wagi wybranego wariantu do jego katalogu.

### Uruchomienie

```bash
# tekst
./run.sh 4-bit "Wyjasnij splatanie kwantowe w jednym zdaniu."

# obraz plus tekst
./run.sh 4-bit "Opisz ten obraz." sciezka/do/obrazu.png
```

Serwer zgodny z API OpenAI (port 8080):

```bash
source .venv/bin/activate
python -m mlx_vlm server --model ./4-bit --port 8080
```

### Instalacja recznie, bez skryptu

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -U "mlx-vlm>=0.6.13" "huggingface_hub[cli]"
hf download orcarouter/Qwen3.8-27B-Uncensored-MLX --include "4-bit/*" --local-dir .
python -m mlx_vlm generate --model ./4-bit --prompt "Czesc!" --max-tokens 256
```

### Najczestsze problemy

- **`No matching distribution found for mlx`**: Python jest za nowy albo to Mac z Intelem.
  Uzyj Pythona 3.12 (`brew install uv`, skrypt sam go dobierze).
- **Zawieszanie sie lub swap**: wariant za duzy na Twoj RAM. Zejdz o jeden poziom.
- **Przerwane pobieranie**: uruchom `./install-mac.sh` ponownie, pobiera tylko brakujace pliki.
- **Usuniecie modelu**: skasuj pliki `*.safetensors` z katalogu wariantu oraz katalog `.cache/`.

## Licencja i zrodla

- Licencja: [Apache 2.0](LICENSE), odziedziczona po modelu bazowym.
- Model bazowy: [Qwen/Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B).
- Wagi MLX: [orcarouter/Qwen3.8-27B-Uncensored-MLX](https://huggingface.co/orcarouter/Qwen3.8-27B-Uncensored-MLX).
- Repozytorium zrodlowe: [onurburak9/Qwen3.8-27B-Uncensored-MLX](https://github.com/onurburak9/Qwen3.8-27B-Uncensored-MLX).
