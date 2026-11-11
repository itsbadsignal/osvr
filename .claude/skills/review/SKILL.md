---
name: review
description: Run the learner's daily OSVR spaced-repetition review from learner/cards.yaml using scripts/srs.py, with free-recall grading.
argument-hint: "[max cards, default 25]"
disable-model-invocation: true
---

# /review $ARGUMENTS

COACH mode rules apply. Keep it fast: 10 to 20 minutes.

1. Run `python3 scripts/srs.py due --limit N` (N = the argument, default 25) to get due cards.
2. For each card show only the prompt. Wait for the learner's free-recall answer (typed, drawn, or code). Never offer options.
3. Compare to the card answer. Grade 0 to 5 (0 blank, 1 wrong, 2 wrong but recognised the answer, 3 correct with effort, 4 correct, 5 instant and complete). Tell the learner the grade and, in one line, what was missing. They may dispute a grade once.
4. Record with `python3 scripts/srs.py grade <card_id> <grade>`.
5. If the script flags a leech (4 or more lapses), stop drilling it. Rewrite or split it with the learner, then `python3 scripts/srs.py reset <card_id>`.
6. Close: cards reviewed, mean grade, leeches handled, and the output of `python3 scripts/srs.py stats`.
