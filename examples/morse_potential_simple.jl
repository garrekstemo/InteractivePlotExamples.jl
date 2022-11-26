using GLMakie
using SomeMakieThemes
set_theme!(theme_retina())

function morse_potential(qs, λ)
    @. 0.5 * λ * (1 - exp(-qs / sqrt(λ)))^2
end

function morse_energies(ns, λ)
    @. (ns + 0.5) - (ns + 0.5)^2 / (2 * λ)
end

function endpoints(energy, λ)
    b = @. sqrt(2 * energy / λ)
    left = @. - sqrt(λ) * log(1 + b)
    right = @. - sqrt(λ) * log(1 - b)
    return left, right
end

q = -10:0.01:30
λ = Observable(5)
ns = @lift(1:$λ)
morse = @lift(morse_potential(q, $λ))
energies = @lift(morse_energies($ns, $λ))

fig = Figure(resolution = (1500, 900))
display(fig)

eq = Label(fig, L"V(q) = \frac{\lambda}{2}( 1 - e^{-q / \sqrt{\lambda}} )")
slabel = Label(fig, @lift("λ = $($λ)"))
s = Slider(fig, range = 1:20, startvalue = 5, width = 300)
connect!(λ, s.value)

fig[1, 2] = vgrid!(
    eq,
    slabel,
    s,
    tellheight = false,
    width = 500
)

ax = Axis(fig[1, 1], title = "Simple Morse Oscillator Model", xlabel = "q", ylabel = "Energy")

lines!(q, morse)

xlims!(-7, 25)
ylims!(-1, 13)

xrange = @lift($(ax.limits)[1][2] - $(ax.limits)[1][1])
xmin = @lift((endpoints.($energies, $λ)[end][1] - $(ax.limits)[1][1]) / $xrange)
xmax = @lift((endpoints.($energies, $λ)[end][2] - $(ax.limits)[1][1]) / $xrange)
hlines!(@lift($energies[end]), xmin = xmin, xmax = xmax)