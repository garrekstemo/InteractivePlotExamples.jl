using GLMakie

x = Observable(rand(50))
y_current = @lift(rand(50))

y1 = @lift(10 .* $x.^2)
y2 = @lift($x .+ randn(50))

ys = [y1, y2]

fig = Figure()
display(fig)
ax = Axis(fig[1, 1], xlabel = "x1", ylabel = "y1")
scatter!(ax, x, y_current)

menu = Menu(fig, options = ["y1","y2"] , default = "y1")
fig[1, 2] = vgrid!(
        Label(fig, "Variable", width = nothing),
        menu,
        tellheight = false, width = 200)
    
 on(menu.selection) do _
    i = to_value(menu.i_selected)
    y_current[] = to_value(ys[i])
end