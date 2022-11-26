# J. P. Dahl and M. Springborg, The Morse Oscillator in Position Space, Momentum Space, and Phase Space, The Journal of Chemical Physics 88, 4535 (1988).

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

λ = Observable(5)
ns = @lift(0:$λ)
q = -10:0.01:30

morse = @lift(morse_potential(q, $λ))
energies = @lift(morse_energies($ns, $λ))
harmonic_energies = @lift(@. sqrt(2 * ($ns + 0.5)))

fig = Figure(resolution = (1500, 900))
display(fig)

eq1 = Label(fig, L"V_m(q) = \frac{\lambda}{2}( 1 - e^{-q / \sqrt{\lambda}} )")
eq2 = Label(fig, L"V_h(q) = \frac{1}{2}q^2")

toggle = Toggle(fig, active = false)
tlabel = Label(fig, "Harmonic on/off")
slabel = Label(fig, @lift("λ = $($λ)"))

s = Slider(fig, range = 1:20, startvalue = 5, width = 300)
connect!(λ, s.value)

fig[1, 2][1, 1] = vgrid!(eq1, eq2, tellheight = false)
fig[1, 2][2, 1] = vgrid!(
    slabel,
    s,
    tellheight = false,
    width = 500
    )
fig[1, 2][3, 1] = grid!(hcat(toggle, tlabel), tellheight = false)
    
ax = Axis(fig[1, 1], title = "Simple Morse Oscillator Model", xlabel = "q", ylabel = "Energy")

lines!(q, morse)
lines_h = lines!(q, 0.5 * q.^2)

xlims!(-7, 25)
ylims!(-1, 15)

xrange = @lift($(ax.limits)[1][2] - $(ax.limits)[1][1])

xmin_m = @lift((endpoints.($energies, $λ)[end][1] - $(ax.limits)[1][1]) / $xrange)
xmax_m = @lift((endpoints.($energies, $λ)[end][2] - $(ax.limits)[1][1]) / $xrange)
xmin_h = @lift((-$(harmonic_energies)[end] - $(ax.limits)[1][1]) / $xrange)
xmax_h = @lift(($(harmonic_energies)[end] - $(ax.limits)[1][1]) / $xrange)

hlines!(@lift($energies[end]), xmin = xmin_m, xmax = xmax_m)
hlines_h = hlines!(@lift((@. $ns + 0.5)[end]), xmin = xmin_h, xmax = xmax_h, visible = false)
connect!(lines_h.visible, toggle.active)
connect!(hlines_h.visible, toggle.active)