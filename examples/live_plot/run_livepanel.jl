using GLMakie
using DataFrames
using CSV
using FileWatching
using SomeMakieThemes
set_theme!(theme_retina())

include("live_panel.jl")

folder = "./examples/live_plot/output/"
livepanel(folder)