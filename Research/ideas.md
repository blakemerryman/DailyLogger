# Daily Logger R&D

- appended data must be wrapped in double quotes (" ... ").





--------------------------------------------------

## Argument Parser

### Flags Dictionary

Array of flag dictionaries. Each flag dictionary contains three pieces of information about a flag:

1. Flag Name (`String`)
2. Does the flag take arguments (`Bool`)
3. Arguments to expect (`Int`)
    - Could potential take a range of arguments in the future
    - For indefinite arguments, number of args to expect should be set to Int.max (or equivalent).
    - arg count not needed if flag doesn't accept args

Each field is error checked.