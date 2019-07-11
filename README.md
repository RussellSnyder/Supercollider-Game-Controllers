# Game Controller Interfaces For Supercollider
## Collection callback triggered dictionaries

Collection of dictionaries that allow for functions to be called when a symbol is clicked on a controller.  Depending on the data that is generated, the function will either recieve a bool (for on or off) or continous data.

### What makes this one different?

This one is call back based creating the ability to have multiple functions fire when pressing the same control.  It decouples the control from the implementation which allows for individual systems to consume the data as it chooses. 

```
// c is a dictionary
c[\X].value(~makeNoise);
// this will run the ~makeNoise function whenever X is clicked on the PS3 controller
```
## TODO

- Finish mapping PS3 controller
- Add state dependant options (like double click or button combos)

