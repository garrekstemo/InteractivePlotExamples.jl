# InteractivePlotExamples.jl

A collection of examples of interactive plots using [GLMakie](https://docs.makie.org).
The excellent website [Beautiful Makie](https://beautiful.makie.org/) has lots of great examples using Makie.jl, but it's still hard to find somewhat more complex examples using GLMakie's interactive features. Making interactive plots in Makie is quite easy compared to a lot of other software, and can be an important part of a workflow for visualizing data or models. Each example is completely self-contained, except if clearly mentioned. Hopefully these examples are a great starting point for more ideas.

Screen recordings of these examples are in the `demos` folder.

## Examples

### Sliders

The slider examples show different ways to use Makie's `Slider` or `SliderGrid`
objects. They show how to update a plot when a function updates. Some of these are quite complicated and many aspects of the plot are interdependent `Observables` that all update with each other. You can use `@lift` to create a web of several linked `Observables` with complex mathematical functions, but the plots still update smoothly.

- Sum of two sines
- Gaussian wavepacket with sine and exponential components and several variables
- Simple Morse potential function with one variable
- More realistic Morse potential for a diatomic molecule
  

### Live plot

The live plot example simulates a device that writes data to a file. It uses FileWatching.jl to watch a folder for a new file, load the data using DataFrames.jl, display the plot, and update the axis limits. In this example, move one of the files in `device` to `output` after running the script.

## Suggestions

If you have a suggestion for other examples, or you have made a cool interactive plot with GLMakie, please let me know and it may be included.

## References

1. J. P. Dahl and M. Springborg, The Morse Oscillator in Position Space, Momentum Space, and Phase Space, The Journal of Chemical Physics 88, 4535 (1988).
2. https://scipython.com/blog/the-morse-oscillator/
3. https://scipython.com/blog/visualizing-vibronic-transitions-in-a-diatomic-molecule/