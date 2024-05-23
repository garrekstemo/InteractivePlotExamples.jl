using GLMakie
using DataFrames
using CSV
using FileWatching

include("live_panel.jl")

folder = "./examples/live_plot/output/"
livepanel(folder)