using GLMakie
using SomeMakieThemes
set_theme!(theme_retina())


function morse_potential(q, q_eq, De, a)
    @. De * (1 - exp(-a * (q - q_eq)))^2
end

function harmonic(q, q_eq, De, a)
    @. De * (-a * (q - q_eq))^2
end

function energy_levels(n, ν_0, ν_exe)
    return @. (n + 0.5) * ν_0 - ν_exe * (n + 0.5)^2
end

function endpoint_left(energy, De, a, q_eq)
    b = @. sqrt(energy / De)
    return @. q_eq - log(1 + b) / a
end

function endpoint_right(energy, De, a, q_eq)
    b = @. sqrt(energy / De)
    return @. q_eq - log(1 - b) / a
end

function endpoint_left_harmonic(energy, De, a, q_eq)
    @. q_eq - sqrt(energy / De) / a
end
function endpoint_right_harmonic(energy, De, a, q_eq)
    @. q_eq + sqrt(energy / De) / a
end

mass_A = 1
mass_B = 1
μ = mass_A * mass_B / (mass_A + mass_B)

q = 0:0.001:40
q_eq = 10
ω_0 = 2
ω_12 = 0.03

a = Observable(0.2)
De = 9.0
De = ω_0^2 / (4 * ω_12)
a = Observable(ω_0 * sqrt(2 * μ / De) * π)
a_harm = ω_0 * sqrt(2 * μ) * π
ns = 0:6

morse = @lift(morse_potential(q, q_eq, De, $a))
harm = @lift(harmonic(q, q_eq, De, $a))
levels = energy_levels(ns, ω_0, ω_12)

harm_levels = ω_0 * (ns .+ 0.5)

fig = Figure(resolution = (1800, 1000))
display(fig)

label = Label(fig, L"V(q) = D_e \left(1 - e^{-a (q - q_{qe})}\right)^2", tellheight = false, width=nothing, height = nothing)
label_de = Label(fig, L"a = \sqrt{k_e / 2D_e}", tellheight = false, width = nothing, height= nothing)
label_ke = Label(fig, L"k_e = \left(\frac{d^2V(q)}{dq^2}\right)_{0}", tellheight = false, width = nothing, height= nothing)

sg = SliderGrid(fig,
        (label = L"a", range = 0.1:0.001:2, startvalue=1),
        tellheight = false,
        width = 500,
)

fig[1, 2] = vgrid!(
        label,
        label_de,
        label_ke,
        sg,
        tellheight=false
)

sliderobservables = [s.value for s in sg.sliders]
connect!(a, sliderobservables[1])

ax = Axis(fig[1, 1], title = "Morse", xlabel = "Intermolecular distance", ylabel = "Energy (arb.)",)
lines!(q, morse, label = "Morse", color = :firebrick4)
lines!(q, harm, label = "harmonic", color = :steelblue3)
ylims!(-1, 40)
xlims!(5, 20)

xrange = @lift($(ax.limits)[1][2] - $(ax.limits)[1][1])

for (i, level) in enumerate(levels)    
    xmin = @lift((endpoint_left(level, De, $a, q_eq) - $(ax.limits)[1][1]) / $xrange)
    xmax = @lift((endpoint_right(level, De, $a, q_eq) - $(ax.limits)[1][1]) / $xrange)
    hlines!(ax, level, xmin = xmin, xmax = xmax, color = :firebrick4)
end

@lift((harm_levels[2] - $(ax.limits)[1][1]) / $xrange)

for (i, level) in enumerate(harm_levels)
    xmin = @lift((endpoint_left_harmonic(level, De, $a, q_eq) - $(ax.limits)[1][1]) / $xrange)
    xmax = @lift((endpoint_right_harmonic(level, De, $a, q_eq) - $(ax.limits)[1][1]) / $xrange)
    hlines!(ax, level, xmin = xmin, xmax = xmax, color = :steelblue3)
end

axislegend(ax)