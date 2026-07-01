local loader = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Libraries/External/ExternalLoader/loader.lua'))()

return function(Packages)
    local TopbarPlusModule = loader.load({
        user = '1ForeverHD',
        repo = 'TopbarPlus',
        branch = 'main'
    }, {
        main_zip = 'TopbarPlus-main',
        src_folder = 'src'
    }, {
        Parent = nil,
        Name = 'TopbarPlusFolder'
    });

    local TopbarModule = TopbarPlusModule:WaitForChild('TopbarPlus-main');
    TopbarModule.Name = 'TopbarPlus'
    TopbarModule.Parent = Packages
    TopbarPlusModule:Destroy()

    return TopbarModule
end
