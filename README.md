# Personal Book Manager

A small terminal app for tracking a personal library and finding the next book to read. It uses Bash, pipelines, background processes, and [Gum](https://github.com/charmbracelet/gum).

## Run it

Requirements: Bash 3.2+ and standard Unix tools (`awk`, `sed`, `column`). Gum is recommended for the full interface; without it, the app uses plain terminal prompts.

```bash
brew install gum       # macOS, if needed
cd book-manager
./app.sh
```

The main menu can browse, add, search, and update books, or generate recommendations. Book statuses are `want-to-read`, `reading`, `finished`, and `owned`. Ratings use a 1–5 scale.

## Architecture

The flow is **UI → workflows → book/recommendation components → data layer → CSV storage**. `app.sh` starts the application and hands control to the UI. The workflows coordinate small programs: library input flows through metadata enrichment into the database, while three independent recommendation programs run concurrently, write candidate streams, and feed a refinement pipeline. Only `data/book_database.sh` reads or writes `data/books.csv`, so storage details do not leak into the rest of the app.

## Personalization

Recommendations combine three perspectives: patterns in the genres already in the library, interests typed at the moment of the request, and an intentionally surprising discovery list. This makes the shortlist respond both to long-term reading habits and to what the reader is curious about today. The discovery agent deliberately adds distance from familiar categories instead of optimizing only for similarity.

## Demo video

Add your narrated demo link here before submitting: **[Demo video — TODO](https://example.com/replace-with-your-demo-link)**. A good 60–90 second demo shows adding a book, searching for it, and running the parallel recommendation workflow.

## Component map

- `ui/`: Gum prompts and formatted output only.
- `workflows/`: coordination, background jobs, waiting, and pipelines.
- `books/`: metadata enrichment and library search interfaces.
- `recommendations/`: three candidate generators and one stdin-based refiner.
- `data/`: the sole storage boundary and the CSV file.

For a direct pipeline example:

```bash
printf 'history\n' | ./books/search_books.sh
printf 'Dune|Frank Herbert|Science Fiction|Because you enjoy epics\n' | \
  ./recommendations/refine_recommendations.sh
```
