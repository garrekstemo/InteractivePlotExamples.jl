# InteractivePlotExamples.jl

A collection of examples of interactive plots using [GLMakie](https://docs.makie.org).
The excellent website [Beautiful Makie](https://beautiful.makie.org/) has lots of great examples using Makie.jl, but it's still hard to find somewhat more complex examples using GLMakie's interactive features. Making interactive plots in Makie is quite easy compared to a lot of other software, and can be an important part of a workflow for visualizing data or models. Each example is completely self-contained, except if clearly mentioned. Hopefully these examples are a great starting point for more ideas.


## Note

Right now I'm testing these on my own machine and I have a theme that works nicely with the Retina displays on macOS computers. You can just delete this dependency and the import statements at the top of the examples.

in the REPL, remove the theme dependency
```
julia> ]
pkg> rm SomeMakieThemes
```

delete at the top of a file:
```
using SomeMakieThemes
set_theme!(theme_retina())
```
