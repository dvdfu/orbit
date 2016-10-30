local Const = {}

Const.colors = {
    [0] = function() return 255, 255, 255, 255 end,
    [1] = function() return 255, 128, 32, 255 end,
    [2] = function() return 128, 255, 32, 255 end,
    [3] = function() return 32, 128, 255, 255 end,
    [4] = function() return 255, 255, 128, 255 end,
}

Const.fonts = {
    titleFont = love.graphics.newFont('res/fonts/babyblue.ttf', 36),
    bodyFont = love.graphics.newFont('res/fonts/babyblue.ttf', 16)
}

Const.weapons = {
    pistol = {
        fireRate = 0.25,
        bulletSpeed = 100
    },
    machineGun = {
        fireRate = 0.05,
        bulletSpeed = 200
    }
}

Const.gradientShader = [[
    uniform vec2 point;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        // pixel.rgb *= sqrt(texture_coords.y);
        return pixel;
    }
]]

Const.spaceShader = [[
    uniform vec2 iResolution;
    uniform float iGlobalTime;
    uniform vec2 iMouse;

    #define iterations 17
    #define formuparam 0.53

    #define volsteps 2
    #define stepsize 0.1

    uniform float zoom;
    #define tile   1
    #define speed  0.010

    #define brightness 0.001
    #define darkmatter 0.300
    #define distfading 0.730
    #define saturation 0.850

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        // get coords and direction
        vec2 uv = screen_coords.xy / iResolution - 0.5;
        uv.y *= iResolution.y / iResolution.x;
        vec3 dir = vec3(uv * zoom, 1.0);
        float time = iGlobalTime * speed + 0.25;

        // mouse rotation
        float a1 = 0.5 + iMouse.x / iResolution.x * 2.0;
        float a2 = 0.8 + iMouse.y / iResolution.y * 2.0;
        mat2 rot1 = mat2(cos(a1), sin(a1), -sin(a1), cos(a1));
        mat2 rot2 = mat2(cos(a2), sin(a2), -sin(a2), cos(a2));
        dir.xz *= rot1;
        dir.xy *= rot2;
        vec3 from = vec3(1.0, 0.5, 0.5);
        from += vec3(time * 2.0, time, -2.0);
        from.xz *= rot1;
        from.xy *= rot2;

        // volumetric rendering
        float s = 0.1, fade = 1.0;
        vec3 v = vec3(0.0);
        for (int r = 0; r < volsteps; r++) {
            vec3 p = from + s * dir * 0.5;
            p = abs(vec3(tile) - mod(p, vec3(tile * 2.0))); // tiling fold
            float pa, a = pa = 0.0;
            for (int i = 0; i < iterations; i++) {
                p = abs(p) / dot(p, p)-formuparam; // the magic formula
                a += abs(length(p) - pa); // absolute sum of average change
                pa = length(p);
            }
            float dm = max(0.0, darkmatter - a * a * 0.001); // dark matter
            a *= a * a; // add contrast
            if (r > 6) fade *= 1.0 - dm; // dark matter, don't render near
            //v += vec3(dm,dm * 0.5, 0.0);
            v += fade;
            v += vec3(s, s * s, s * s * s * s) * a * brightness * fade; // coloring based on distance
            fade *= distfading; // distance fading
            s += stepsize;
        }
        v = mix(vec3(length(v)), v, saturation); //color adjust
        return vec4(v * 0.01, 1.0);
    }

    vec4 position(mat4 transform_projection, vec4 vertex_position) {
        return transform_projection * vertex_position;
    }
]]

return Const
