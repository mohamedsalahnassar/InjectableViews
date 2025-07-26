//@attached(member)
@attached(accessor)
public macro InjectableView() = #externalMacro(
    module: "InjectableViewsMacros",
    type:   "InjectableViewMacro"
)
