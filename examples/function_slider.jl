using GLMakie
using SomeMakieThemes

set_theme!(theme_retina())

x = -2π:0.1:2π
A = Observable(1.0)
σ = Observable(1.0)
# f(x, A, σ) = @. A * sin(x) * exp( -x^2 / (2 * σ^2) )

y = @lift(@. $A * sin($x) * exp(- $x^2 / (2 * $σ^2)))

fig = Figure()
display(fig)

ax = Axis(fig[1, 1], ylabel = "y", xlabel = "x")

lines!(x, y)

# tight_ticklabel_spacing!(ax)

# sg = SliderGrid(fig[2, 1],
#     (label = "Amplitude", range = 0:0.01:10, format = "{:.1f}", startvalue=1)
# )

# function update()
#     A[] = to_value(A)
#     σ[] = to_value(σ)
#     oy[] = y(x, A[], σ[])
#     autolimits!(ax)
# end


# for slider in sg.sliders
#     on(slider.value) do val
#         update()
#     end
# end