using GLMakie
using DataFrames
using CSV
using FileWatching
using SomeMakieThemes
set_theme!(theme_retina())

include("live_panel.jl")

folder = "./example_data/output/"
livepanel(folder)