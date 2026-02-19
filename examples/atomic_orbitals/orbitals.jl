using GLMakie
using ClassicalOrthogonalPolynomials
using HarmonicOrthogonalPolynomials
using Colors
using ColorSchemes
include("functions.jl")


n, l, m = 3, 2, 0
rmax = 30
N = 200
x = y = z = range(-rmax, rmax, length = N)
ψ, ρ = orbital_density(n, l, m, x, y, z)

ψ ./= maximum(ψ)
ρ ./= maximum(ρ)

zslice = length(z) ÷ 2
ψ_slice = ψ[zslice, :, :]
ρ_slice = ρ[zslice, :, :]
zmin, zmax = minimum(z), maximum(z)
ψ_xy = dropdims(sum(ψ, dims=3), dims=3)
ψ_xz = dropdims(sum(ψ, dims=2), dims=2)
ψ_yz = dropdims(sum(ψ, dims=1), dims=1)

cmap = :Egypt

f = Figure(size = (800, 500))

ax1 = Axis3(f[1, 1])

# Absorption algo is kinda cool -- it changes with viewing angle
# volume!(x[1]..x[end], y[1]..y[end], z[1]..z[end],
#     ψ,
#     colormap = cmap,
#     algorithm = :absorption,
#     transparency = true,
#     absorption = 0.9
#     )

# Makes a nice looking solid volume
isos = [-0.9, -0.6, -0.3, 0, 0.3, 0.6, 0.9]
i_val = 1.4
# isos = -i_val:0.3:i_val
for iso in isos
    volume!(x[1]..x[end], y[1]..y[end], z[1]..z[end],
        ψ,
        algorithm = :iso,
        isovalue = iso,
        isorange = 0.04,
        colormap = cmap,
        transparency = true,
        )
end

contour!(x, y, ψ_xy,
    levels = 20,
    colormap = cmap,
    transformation = (:xy, zmin),
    transparency = true
    )
contour!(x, y, ψ_xz,
    levels = 20,
    colormap = cmap,
    transformation = (:xz, zmax),
    transparency = true
    )
contour!(x, y, ψ_yz,
    levels = 20,
    colormap = cmap,
    transformation = (:yz, zmax),
    transparency = true
    )


ax2 = Axis(f[1, 2], title = "Cut Plane through z", aspect = 1)

hm = heatmap!(x, y, 
    ψ_slice,
    # ρ_slice,
    colormap = cmap,
    )
Colorbar(f[1, 3], hm)

f
