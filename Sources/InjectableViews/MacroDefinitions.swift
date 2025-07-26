@attached(peer, names: arbitrary)
@attached(accessor)
public macro InjectableView() = #externalMacro(
    module: "InjectableViewsMacros",
    type:   "InjectableViewMacro"
)
