using BinDeps
using Compat

CSIP_VERSION = "0.3.2"
CSIP_URL = "https://github.com/SCIP-Interfaces/CSIP/archive/v$(CSIP_VERSION).zip"
CSIP_LIB = "libcsip"
CSIP_UNPACKED = "CSIP-$(CSIP_VERSION)"

@BinDeps.setup

@assert haskey(ENV, "SCIPOPTDIR") "Environment variable `SCIPOPTDIR` not set!"

function validate_csip(name, handle)
    csip_version = ccall(Libdl.dlsym(handle, :CSIPgetVersion), Cint, ())
    csip_version == 032
end

csipdep = library_dependency(CSIP_LIB, validate=validate_csip)

@compat provides(Sources, Dict(URI(CSIP_URL) => csipdep),
                 unpacked_dir=CSIP_UNPACKED)

@compat provides(SimpleBuild,
    (@build_steps begin
         GetSources(csipdep)
         @build_steps begin
             ChangeDirectory(joinpath(BinDeps.srcdir(csipdep), CSIP_UNPACKED))
             `make`
             `mkdir -p $(libdir(csipdep))`
             `install lib/libcsip.so $(libdir(csipdep))`
         end
    end), csipdep, os = :Unix)

@compat @BinDeps.install Dict(:libcsip => :libcsip)
