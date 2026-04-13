# EarFuck - A Musical Brainfuck Substitution

Earfuck encodes the traditional brainfuck instructions as notes in a MIDI file.

Currently we only go from MIDI -> brainfuck, but it would be nice if I'm ever feeling motivated enough to create a secondary translator for brainfuck -> MIDI

These are the mappings:

- `+` : `B4`
- `-` : `C4`
- `<` : `F5`
- `>` : `G5`
- `[`: `B2`
- `]` : `C3`
- `.` : `F4`
- `,` :`E4`

This was chosen pretty randomly while staring at a MIDI keyboard lol

## Known Errors
This was thrown together in a single morning, the MIDI parsing is very lazy. Currently for whatever reason the first note is ignored, consider this an opportunity to make the first note whatever your heart desires before your program begins <3
