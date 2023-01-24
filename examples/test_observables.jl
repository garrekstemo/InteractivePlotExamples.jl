using GLMakie

f(x, a) = a + x

fig = Figure()
display(fig)

a = Observable{Int}()
s = Slider(fig, range = 1:10, startvalue = 3, width = 300)
slabel = Label(fig, @lift("a = $($a)"))
connect!(a, s.value)

x = @lift(0:$a)

fig[1, 2] = vgrid!(slabel, s, tellheight = false)

ax = Axis(fig[1, 1])
xlims!(-10, 10)

xrange = @lift($(ax.limits)[1][2] - $(ax.limits)[1][1])
xmin = @lift(@. (-f($x, $a) - $(ax.limits)[1][1]) / $xrange)
xmax = @lift(@. (f($x, $a) - $(ax.limits)[1][1]) / $xrange)

hlines!(@lift(f.($x, $a)), xmin = xmin, xmax = xmax)

# Diagnostic print statements
on(s.value) do val
    println("slider: ", val)
    println("a: ", a[])
    println("x: ", length(x[]))
    println("f:", length(f.(x[], a[])))
    println("min:", length(xmin[]))
    println("max:", length(xmax[]))
    println("")
end