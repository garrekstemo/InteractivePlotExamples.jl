# Based on
# J. P. Dahl and M. Springborg, The Morse Oscillator in Position Space, Momentum Space, and Phase Space, The Journal of Chemical Physics 88, 4535 (1988).
# and
# https://scipython.com/blog/the-morse-oscillator/

using GLMakie
using SomeMakieThemes
set_theme!(theme_retina())

const u = 1.6605390666e-27  # atomic mass constant
const c_0 = 3e8
const h = 6.62607015e-34
const ħ = h / 2π
const joules = 100 * h * c_0

"""
    morse(q, λ)

λ and q parameterize several molecular parameters.

λ = √(2 * m * D / (α * ħ))

q = (m * ω_0 / ħ)^(1/2) * x = α * √λ * x
"""
function morse_potential(q, q_e, D, a)
    @. D * (1 - exp(-a * (q - q_e)))^2
end

function harmonic_potential(q, q_e, D, a)
    @. D * a^2 * (q - q_e)^2
end

function morse_energies(n, ω_0, ω0χ0)
    @. ω_0 * (n + 0.5) - ω0χ0 * (n + 0.5)^2
end

function endpoints_morse(energy, q_eq, D, a)
    b = @. sqrt(energy / D)
    left = @. q_eq - log(1 + b) / a
    right = @. q_eq - log(1 - b) / a
    return left, right
end

function endpoints_harmonic(energies, q_eq, D, a)
    left = @. q_eq - sqrt(energies / D) / a
    right = @. q_eq + sqrt(energies / D) / a
    return left, right
end

ω_0 = Observable(2990.945)
ω0χ = Observable(52.818595)

mass_A = 1
mass_B = 35
μ = mass_A * mass_B / (mass_A + mass_B) * u
D = @lift($ω_0^2 / (4 * $ω0χ) * joules)
k = @lift((2π * c_0 * 100 * $ω_0)^2 * μ)
a = @lift($ω_0 * π * c_0 * 100 * sqrt(2 * μ / $D))
λ = @lift(sqrt(2 * μ * $D) / ($a * ħ))

n_max = @lift(Int(floor($λ - 0.5)))

ns =@lift(0:$n_max)
q_e = 1.27455e-10
q_min = q_e - log(5) / to_value(a)
q_max = q_e - log(1 - 0.9999999) / to_value(a)
q = range(q_min, q_max, length = 1000)


morse = @lift(morse_potential(q, q_e, $D, $a))
harmonic = @lift(harmonic_potential(q, q_e, $D, $a))
energies = @lift(morse_energies($ns, $ω_0, $ω0χ))
harmonic_energies = @lift(@. $ω_0 * ($ns + 0.5))


fig = Figure(resolution = (1800, 1000))
display(fig)
DataInspector(fig)

sg = SliderGrid(fig,
        (label = L"ω_0", range = 1000:0.1:10000, startvalue=3000),
        (label = L"ω_0χ", range = 1:0.1:200, startvalue=50),
        tellheight = false,
        width = 500,
)

fig[1, 2] = vgrid!(
        sg,
        tellheight=false
)

sliderobservables = [s.value for s in sg.sliders]
connect!(ω_0, sliderobservables[1])
connect!(ω0χ, sliderobservables[2])

ax = Axis(fig[1, 1], title = "Diatomic potential model", xlabel = "Intermolecular distance (Å)", ylabel = "Wavenumbers (cm⁻¹)",)
lines!(q .* 1e10, @lift($morse ./ joules), label = "Morse", color = :firebrick4)
lines!(q .* 1e10, @lift($harmonic ./ joules), label = "harmonic", color = :steelblue3)

ylims!(-1, 1e5)
xlims!(0, 6)

xrange = @lift($(ax.limits)[1][2] - $(ax.limits)[1][1])

i = 5

xmin_m = @lift((endpoints_morse($energies .* joules, q_e, $D, $a)[1][i] - $(ax.limits)[1][1]) / $xrange .* 1e10)
xmax_m = @lift((endpoints_morse($energies .* joules, q_e, $D, $a)[2][i] - $(ax.limits)[1][1]) / $xrange .* 1e10)
xmin_h = @lift((endpoints_harmonic($harmonic_energies .* joules, q_e, $D, $a)[1][i] - $(ax.limits)[1][1]) / $xrange * 1e10)
xmax_h = @lift((endpoints_harmonic($harmonic_energies .* joules, q_e, $D, $a)[2][i] - $(ax.limits)[1][1]) / $xrange * 1e10)

hlines!(@lift(morse_energies($ns, $ω_0, $ω0χ)[i]), xmin = xmin_m, xmax = xmax_m, color = :firebrick4)
hlines!(@lift(@. $ω_0 * ($ns + 0.5)[i]), xmin = xmin_h, xmax = xmax_h, color = :steelblue3)

axislegend(ax)
