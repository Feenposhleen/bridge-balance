shader_type spatial;
render_mode world_vertex_coords;

const int MAX_ZONES = 100;
const float ZONE_RADIUS = 20.0;
const float ZONE_FALLOFF = 15.0;

uniform float zone_positions[MAX_ZONES];
uniform float zone_tilts[MAX_ZONES];

void vertex() {
    vec3 pos = VERTEX;

    for (int i = 0; i < MAX_ZONES; i++) {
        float zone_tilt = zone_tilts[i];
        if (zone_tilt == 0.0) continue;

        float zone_position = zone_positions[i];
        float z_distance_to_zone = abs(pos.z - zone_position);
        float zone_influence = 1.0 - smoothstep(ZONE_RADIUS, ZONE_RADIUS + ZONE_FALLOFF, z_distance_to_zone);
        if (zone_influence <= 0.0) continue;

        float angle = -1.0 * zone_tilt * zone_influence;
        float cos_a = cos(angle);
        float sin_a = sin(angle);
        float x_new = pos.x * cos_a - pos.y * sin_a;
        float y_new = pos.x * sin_a + pos.y * cos_a;
        pos.x = x_new;
        pos.y = y_new;
    }

    VERTEX = pos;
}

uniform sampler2D albedo_texture;
uniform sampler2D normal_texture;
uniform sampler2D rough_texture;

void fragment() {
	ALBEDO = texture(albedo_texture, UV).xyz;
	NORMAL_MAP = texture(normal_texture, UV).xyz;
	ROUGHNESS = texture(rough_texture, UV).x;
}
