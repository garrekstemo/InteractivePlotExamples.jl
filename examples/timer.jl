using GLMakie
using SomeMakieThemes

set_theme!(theme_retina())

x = Observable(rand(10))
y = Observable(rand(10))


fig = Figure()
display(fig)

button = Button(fig[2, 1], tellwidth = false)

ax = Axis(fig[1, 1])

lines!(x, y)

function cb(timer)
    x[] = rand(10)
    y[] = rand(10)
    autolimits!(ax)
    tight_ticklabel_spacing!(ax)
end

on(button.clicks) do _
    timer = Timer(cb, 3)
end