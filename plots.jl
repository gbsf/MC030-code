using DelimitedFiles
using Plots, Plots.PlotMeasures
gr()

blackscholes_f16_small  = readdlm("blackscholes_f16_small.txt", ' ', Float64; skipstart=1)[:]
blackscholes_f32_small  = readdlm("blackscholes_f32_small.txt", ' ', Float64; skipstart=1)[:]
blackscholes_f64_small  = readdlm("blackscholes_f64_small.txt", ' ', Float64; skipstart=1)[:]
blackscholes_f16a_small = readdlm("blackscholes_f16a_small.txt", ' ', Float64; skipstart=1)[:]
blackscholes_f8_small   = readdlm("blackscholes_f8_small.txt", ' ', Float64; skipstart=1)[:]

blackscholes_float_small  = readdlm("blackscholes_float_small.txt", ' ', Float64; skipstart=1)[:]
blackscholes_double_small = readdlm("blackscholes_double_small.txt", ' ', Float64; skipstart=1)[:]

blackscholes_f16_large  = readdlm("blackscholes_f16_large.txt", ' ', Float64; skipstart=1)[:]
blackscholes_f32_large  = readdlm("blackscholes_f32_large.txt", ' ', Float64; skipstart=1)[:]
blackscholes_f64_large  = readdlm("blackscholes_f64_large.txt", ' ', Float64; skipstart=1)[:]
blackscholes_f16a_large = readdlm("blackscholes_f16a_large.txt", ' ', Float64; skipstart=1)[:]

blackscholes_float_large  = readdlm("blackscholes_float_large.txt", ' ', Float64; skipstart=1)[:]
blackscholes_double_large = readdlm("blackscholes_double_large.txt", ' ', Float64; skipstart=1)[:]


min_small = round(minimum(blackscholes_double_small))
max_small = round(maximum(blackscholes_double_small)/5)*5

min_large = round(minimum(blackscholes_double_large))
max_large = round(maximum(blackscholes_double_large)/5)*5

function blackscholes_small(w::Int, vec::AbstractVector, sub::AbstractChar; name::String="$w-bit", fid::String="$w")
    idx = vec .> max_small
    a = plot([0, max_small], [0, max_small]; title="($sub) simsmall: $name FPnew vs 64-bit native", color=:red, legend=:none, linestyle=:dash, left_margin=80px)
    a = scatter!(a, blackscholes_double_small[.~idx], vec[.~idx]; color=:steelblue, limit=(min_small, max_small), ywiden=true, xwiden=false)
    a = scatter!(a, blackscholes_double_small[idx], repeat([max_large]; inner=sum(idx)); color=:red, m=:x)
    b = sticks(blackscholes_double_small, blackscholes_double_small-vec; linecolor=:black, fillcolor=nothing, legend=:none, title="Residual", xlimit=(min_small, max_small))

    c = plot(a, b; layout=(2,1), link=:x, size=(1200, 300))

    savefig(c, "blackscholes_small_$fid.png")
end

function blackscholes_large(w::Int, vec::AbstractVector, sub::AbstractChar; name::String="$w-bit", fid::String="$w")
    idx = vec .> max_large
    a = plot([0, max_large], [0, max_large]; title="($sub) simlarge: $name FPnew vs 64-bit native", color=:red, legend=:none, linestyle=:dash, left_margin=80px)
    a = scatter!(a, blackscholes_double_large[.~idx], vec[.~idx]; color=:steelblue, limit=(min_large, max_large), ywiden=true, xwiden=false)
    a = scatter!(a, blackscholes_double_large[idx], repeat([max_large]; inner=sum(idx)); color=:red, m=:x)
    b = sticks(blackscholes_double_large, blackscholes_double_large-vec; linecolor=:black, fillcolor=nothing, legend=:none, title="Residual", xlimit=(min_large, max_large))

    c = plot(a, b; layout=(2,1), link=:x, size=(1200, 300))

    savefig(c, "blackscholes_large_$fid.png")
end

blackscholes_small(16, blackscholes_f16_small, 'a')
blackscholes_small(32, blackscholes_f32_small, 'b')
blackscholes_small(64, blackscholes_f64_small, 'c')
blackscholes_small(16, blackscholes_f16a_small, 'd'; name = "16-bit alternate", fid = "16a")
blackscholes_small(8, blackscholes_f8_small, 'e')

blackscholes_large(16, blackscholes_f16_large, 'a')
blackscholes_large(32, blackscholes_f32_large, 'b')
blackscholes_large(64, blackscholes_f64_large, 'c')
blackscholes_large(16, blackscholes_f16a_large, 'd'; name = "16-bit alternate", fid = "16a")

f16s_idx = .~((blackscholes_f16_small .> 30) .| ((blackscholes_f16_small .== 0.) .& (blackscholes_double_small .!= 0.)) .| (blackscholes_double_small .== 0.))
err16s = (blackscholes_double_small[f16s_idx].-blackscholes_f16_small[f16s_idx])./blackscholes_double_small[f16s_idx]
bs_mape16s = 100sum(abs.(err16s))/length(err16s)
f32s_idx = .~((blackscholes_f32_small .> 30) .| ((blackscholes_f32_small .== 0.) .& (blackscholes_double_small .!= 0.)) .| (blackscholes_double_small .== 0.))
err32s = (blackscholes_double_small[f32s_idx].-blackscholes_f32_small[f32s_idx])./blackscholes_double_small[f32s_idx]
bs_mape32s = 100sum(abs.(err32s))/length(err32s)
f64s_idx = .~((blackscholes_f64_small .> 30) .| ((blackscholes_f64_small .== 0.) .& (blackscholes_double_small .!= 0.)) .| (blackscholes_double_small .== 0.))
err64s = (blackscholes_double_small[f64s_idx].-blackscholes_f64_small[f64s_idx])./blackscholes_double_small[f64s_idx]
bs_mape64s = 100sum(abs.(err64s))/length(err64s)
f16as_idx = .~((blackscholes_f16a_small .> 30) .| ((blackscholes_f16a_small .== 0.) .& (blackscholes_double_small .!= 0.)) .| (blackscholes_double_small .== 0.))
err16as = (blackscholes_double_small[f16as_idx].-blackscholes_f16a_small[f16as_idx])./blackscholes_double_small[f16as_idx]
bs_mape16as = 100sum(abs.(err16as))/length(err16as)
f8s_idx = .~((blackscholes_f8_small .> 30) .| ((blackscholes_f8_small .== 0.) .& (blackscholes_double_small .!= 0.)) .| (blackscholes_double_small .== 0.))
err8s = (blackscholes_double_small[f8s_idx].-blackscholes_f8_small[f8s_idx])./blackscholes_double_small[f8s_idx]
bs_mape8s = 100sum(abs.(err8s))/length(err8s)

f16l_idx = .~((blackscholes_f16_large .> 30) .| ((blackscholes_f16_large .== 0.) .& (blackscholes_double_large .!= 0.)) .| (blackscholes_double_large .== 0.))
err16l = (blackscholes_double_large[f16l_idx].-blackscholes_f16_large[f16l_idx])./blackscholes_double_large[f16l_idx]
bs_mape16l = 100sum(abs.(err16l))/length(err16l)
f32l_idx = .~((blackscholes_f32_large .> 30) .| ((blackscholes_f32_large .== 0.) .& (blackscholes_double_large .!= 0.)) .| (blackscholes_double_large .== 0.))
err32l = (blackscholes_double_large[f32l_idx].-blackscholes_f32_large[f32l_idx])./blackscholes_double_large[f32l_idx]
bs_mape32l = 100sum(abs.(err32l))/length(err32l)
f64l_idx = .~((blackscholes_f64_large .> 30) .| ((blackscholes_f64_large .== 0.) .& (blackscholes_double_large .!= 0.)) .| (blackscholes_double_large .== 0.))
err64l = (blackscholes_double_large[f64l_idx].-blackscholes_f64_large[f64l_idx])./blackscholes_double_large[f64l_idx]
bs_mape64l = 100sum(abs.(err64l))/length(err64l)
f16al_idx = .~((blackscholes_f16a_large .> 30) .| ((blackscholes_f16a_large .== 0.) .& (blackscholes_double_large .!= 0.)) .| (blackscholes_double_large .== 0.))
err16al = (blackscholes_double_large[f16al_idx].-blackscholes_f16a_large[f16al_idx])./blackscholes_double_large[f16al_idx]
bs_mape16al = 100sum(abs.(err16al))/length(err16al)

bs_rmsd16s = sqrt(sum((blackscholes_double_small.-blackscholes_f16_small).^2)/length(blackscholes_double_small))
bs_rmsd32s = sqrt(sum((blackscholes_double_small.-blackscholes_f32_small).^2)/length(blackscholes_double_small))
bs_rmsd64s = sqrt(sum((blackscholes_double_small.-blackscholes_f64_small).^2)/length(blackscholes_double_small))
bs_rmsd16as = sqrt(sum((blackscholes_double_small.-blackscholes_f16a_small).^2)/length(blackscholes_double_small))
bs_rmsd8s = sqrt(sum((blackscholes_double_small.-blackscholes_f8_small).^2)/length(blackscholes_double_small))

bs_rmsd16l = sqrt(sum((blackscholes_double_large.-blackscholes_f16_large).^2)/length(blackscholes_double_large))
bs_rmsd32l = sqrt(sum((blackscholes_double_large.-blackscholes_f32_large).^2)/length(blackscholes_double_large))
bs_rmsd64l = sqrt(sum((blackscholes_double_large.-blackscholes_f64_large).^2)/length(blackscholes_double_large))
bs_rmsd16al = sqrt(sum((blackscholes_double_large.-blackscholes_f16a_large).^2)/length(blackscholes_double_large))

print("16 & ", bs_mape16s, " & ", bs_rmsd16s, " & ", bs_mape16l, " & ", bs_rmsd16l, " \\\\\n")
print("32 & ", bs_mape32s, " & ", bs_rmsd32s, " & ", bs_mape32l, " & ", bs_rmsd32l, " \\\\\n")
print("64 & ", bs_mape64s, " & ", bs_rmsd64s, " & ", bs_mape64l, " & ", bs_rmsd64l, " \\\\\n")
print("16a & ", bs_mape16as, " & ", bs_rmsd16as, " & ", bs_mape16al, " & ", bs_rmsd16al, " \\\\\n")
print("8 & ", bs_mape8s, " & ", bs_rmsd8s, " & {---} & {---} \\\\\n")

swaptions_f16_tiny = readdlm("swaptions_f16_tiny.txt", ' ', Float64; skipstart=3)[:,1]
swaptions_f32_tiny = readdlm("swaptions_f32_tiny.txt", ' ', Float64; skipstart=3)[:,1]
swaptions_f64_tiny = readdlm("swaptions_f64_tiny.txt", ' ', Float64; skipstart=3)[:,1]

for (i, (f16, f32, f64)) in enumerate(zip(swaptions_f16_tiny, swaptions_f32_tiny, swaptions_f64_tiny))
    sf16 = (isnan(f16) || isinf(f16)) ? "& {\\texttt{$f16}} " : "& $f16 "
    sf32 = (isnan(f32) || isinf(f32)) ? "& {\\texttt{$f32}} " : "& $f32 "
    sf64 = (isnan(f64) || isinf(f64)) ? "& {\\texttt{$f64}} " : "& $f64 "
    print(i, ' ', sf16, sf32, sf64, "\\\\\n")
end

diff16 = filter(x -> !isnan(x)&&!isinf(x), swaptions_f64_tiny.-swaptions_f16_tiny)
mape16 = 100sum(abs.(diff16)./filter(x -> !isnan(x)&&!isinf(x), swaptions_f16_tiny))/length(diff16)
rmsd16 = sqrt(sum(diff16.^2)/length(diff16))

diff32 = filter(x -> !isnan(x)&&!isinf(x), swaptions_f64_tiny.-swaptions_f32_tiny)
mape32 = 100sum(abs.(diff32)./filter(x -> !isnan(x)&&!isinf(x), swaptions_f32_tiny))/length(diff32)
rmsd32 = sqrt(sum(diff32.^2)/length(diff32))

print("\\midrule\n")
print("MAPE & {\\SI[round-mode=places,round-precision=2]{", mape16, "}{\\percent}\\tnote{\\textdagger}} & {\\SI[round-mode=places,round-precision=2]{", mape32, "}{\\percent}} & {---} \\\\\n")
print("RMSD & {\\num[round-mode=places,round-precision=2]{", rmsd16, "}\\tnote{\\textdagger}} & {\\num[round-mode=places,round-precision=2]{", rmsd32, "}} & {---} \\\\\n")

max_swaptions = maximum(swaptions_f64_tiny)
min_swaptions = 0
a = plot([0, max_swaptions], [0, max_swaptions]; title="FPnew vs 64-bit native", color=:red, legend=:none, linestyle=:dash)
a = scatter!(a, swaptions_f64_tiny, swaptions_f16_tiny; color=:steelblue, xlimit=(min_swaptions, max_swaptions), widen=true)
b = sticks(swaptions_f64_tiny, swaptions_f64_tiny.-swaptions_f16_tiny; linecolor=:black, fillcolor=nothing, legend=:none, title="Residual", xlimit=(min_swaptions, max_swaptions), widen=true)
sw_errors = swaptions_f64_tiny[isnan.(swaptions_f16_tiny) .| isinf.(swaptions_f16_tiny)]
b = scatter!(b, sw_errors, repeat([0], inner=length(sw_errors)); m = :x, color=:red, legend=:none)

c = plot(a, b; layout=(2,1), link=:x, size=(1200, 500))

savefig(c, "swaptions_tiny.png")
