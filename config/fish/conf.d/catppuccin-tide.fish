# Catppuccin theme for Tide
# https://catppuccin.com/palette/
#
# Usage: Add to your ~/.config/fish/config.fish:
#   catppuccin_tide mocha lean  # or classic, rainbow
#   catppuccin_tide latte classic
#   catppuccin_tide frappe rainbow

function _catppuccin_tide_palette -a variant
    switch $variant
        case latte
            set -g _ctp_text 4c4f69
            set -g _ctp_base eff1f5
            set -g _ctp_surface1 bcc0cc
            set -g _ctp_overlay1 8c8fa1
            set -g _ctp_overlay2 7c7f93
            set -g _ctp_sky 04a5e5
            set -g _ctp_sapphire 209fb5
            set -g _ctp_blue 1e66f5
            set -g _ctp_teal 179299
            set -g _ctp_yellow df8e1d
            set -g _ctp_green 40a02b
            set -g _ctp_peach fe640b
            set -g _ctp_red d20f39
            set -g _ctp_mauve 8839ef
            set -g _ctp_lavender 7287fd
            set -g _ctp_pink ea76cb
            set -g _ctp_rosewater dc8a78
            set -g _ctp_maroon e64553
        case frappe
            set -g _ctp_text c6d0f5
            set -g _ctp_base 303446
            set -g _ctp_surface1 51576d
            set -g _ctp_overlay1 838ba7
            set -g _ctp_overlay2 949cbb
            set -g _ctp_sky 99d1db
            set -g _ctp_sapphire 85c1dc
            set -g _ctp_blue 8caaee
            set -g _ctp_teal 81c8be
            set -g _ctp_yellow e5c890
            set -g _ctp_green a6d189
            set -g _ctp_peach ef9f76
            set -g _ctp_red e78284
            set -g _ctp_mauve ca9ee6
            set -g _ctp_lavender babbf1
            set -g _ctp_pink f4b8e4
            set -g _ctp_rosewater f2d5cf
            set -g _ctp_maroon ea999c
        case macchiato
            set -g _ctp_text cad3f5
            set -g _ctp_base 24273a
            set -g _ctp_surface1 494d64
            set -g _ctp_overlay1 8087a2
            set -g _ctp_overlay2 939ab7
            set -g _ctp_sky 91d7e3
            set -g _ctp_sapphire 7dc4e4
            set -g _ctp_blue 8aadf4
            set -g _ctp_teal 8bd5ca
            set -g _ctp_yellow eed49f
            set -g _ctp_green a6da95
            set -g _ctp_peach f5a97f
            set -g _ctp_red ed8796
            set -g _ctp_mauve c6a0f6
            set -g _ctp_lavender b7bdf8
            set -g _ctp_pink f5bde6
            set -g _ctp_rosewater f4dbd6
            set -g _ctp_maroon ee99a0
        case mocha
            set -g _ctp_text cdd6f4
            set -g _ctp_base 1e1e2e
            set -g _ctp_surface1 45475a
            set -g _ctp_overlay1 7f849c
            set -g _ctp_overlay2 9399b2
            set -g _ctp_sky 89dceb
            set -g _ctp_sapphire 74c7ec
            set -g _ctp_blue 89b4fa
            set -g _ctp_teal 94e2d5
            set -g _ctp_yellow f9e2af
            set -g _ctp_green a6e3a1
            set -g _ctp_peach fab387
            set -g _ctp_red f38ba8
            set -g _ctp_mauve cba6f7
            set -g _ctp_lavender b4befe
            set -g _ctp_pink f5c2e7
            set -g _ctp_rosewater f5e0dc
            set -g _ctp_maroon eba0ac
        case '*'
            set -g _ctp_text cdd6f4
            set -g _ctp_base 1e1e2e
            set -g _ctp_surface1 45475a
            set -g _ctp_overlay1 7f849c
            set -g _ctp_overlay2 9399b2
            set -g _ctp_sky 89dceb
            set -g _ctp_sapphire 74c7ec
            set -g _ctp_blue 89b4fa
            set -g _ctp_teal 94e2d5
            set -g _ctp_yellow f9e2af
            set -g _ctp_green a6e3a1
            set -g _ctp_peach fab387
            set -g _ctp_red f38ba8
            set -g _ctp_mauve cba6f7
            set -g _ctp_lavender b4befe
            set -g _ctp_pink f5c2e7
            set -g _ctp_rosewater f5e0dc
            set -g _ctp_maroon eba0ac
    end
end

function _catppuccin_tide_set_pairs
    set -l pairs $argv
    for i in (seq 1 2 (count $pairs))
        set -l key $pairs[$i]
        set -l val $pairs[(math $i + 1)]
        set -U $key $val
    end
end

function _catppuccin_tide_apply_colors
    _catppuccin_tide_set_pairs \
        tide_aws_color $_ctp_peach \
        tide_bun_color $_ctp_rosewater \
        tide_character_color $_ctp_green \
        tide_character_color_failure $_ctp_red \
        tide_cmd_duration_color $_ctp_overlay1 \
        tide_context_color_default $_ctp_peach \
        tide_context_color_root $_ctp_yellow \
        tide_context_color_ssh $_ctp_peach \
        tide_crystal_color $_ctp_text \
        tide_direnv_color $_ctp_yellow \
        tide_direnv_color_denied $_ctp_red \
        tide_distrobox_color $_ctp_pink \
        tide_docker_color $_ctp_blue \
        tide_elixir_color $_ctp_mauve \
        tide_gcloud_color $_ctp_blue \
        tide_git_color_branch $_ctp_green \
        tide_git_color_conflicted $_ctp_red \
        tide_git_color_dirty $_ctp_yellow \
        tide_git_color_operation $_ctp_red \
        tide_git_color_staged $_ctp_yellow \
        tide_git_color_stash $_ctp_green \
        tide_git_color_untracked $_ctp_sky \
        tide_git_color_upstream $_ctp_green \
        tide_go_color $_ctp_sapphire \
        tide_java_color $_ctp_peach \
        tide_jobs_color $_ctp_green \
        tide_kubectl_color $_ctp_blue \
        tide_nix_shell_color $_ctp_sapphire \
        tide_node_color $_ctp_green \
        tide_php_color $_ctp_lavender \
        tide_private_mode_color $_ctp_text \
        tide_prompt_color_frame_and_connection $_ctp_overlay1 \
        tide_prompt_color_separator_same_color $_ctp_overlay2 \
        tide_pulumi_color $_ctp_yellow \
        tide_pwd_color_anchors $_ctp_sky \
        tide_pwd_color_dirs $_ctp_blue \
        tide_pwd_color_truncated_dirs $_ctp_overlay1 \
        tide_python_color $_ctp_teal \
        tide_ruby_color $_ctp_maroon \
        tide_rustc_color $_ctp_peach \
        tide_shlvl_color $_ctp_yellow \
        tide_status_color $_ctp_green \
        tide_status_color_failure $_ctp_red \
        tide_terraform_color $_ctp_mauve \
        tide_time_color $_ctp_teal \
        tide_toolbox_color $_ctp_mauve \
        tide_vi_mode_color_default $_ctp_overlay1 \
        tide_vi_mode_color_insert $_ctp_teal \
        tide_vi_mode_color_replace $_ctp_green \
        tide_vi_mode_color_visual $_ctp_peach \
        tide_zig_color $_ctp_yellow
end

function _catppuccin_tide_apply_lean
    _catppuccin_tide_set_pairs \
        tide_aws_bg_color normal \
        tide_bun_bg_color normal \
        tide_cmd_duration_bg_color normal \
        tide_context_bg_color normal \
        tide_crystal_bg_color normal \
        tide_direnv_bg_color normal \
        tide_direnv_bg_color_denied normal \
        tide_distrobox_bg_color normal \
        tide_docker_bg_color normal \
        tide_elixir_bg_color normal \
        tide_gcloud_bg_color normal \
        tide_git_bg_color normal \
        tide_git_bg_color_unstable normal \
        tide_git_bg_color_urgent normal \
        tide_go_bg_color normal \
        tide_java_bg_color normal \
        tide_jobs_bg_color normal \
        tide_kubectl_bg_color normal \
        tide_nix_shell_bg_color normal \
        tide_node_bg_color normal \
        tide_os_bg_color normal \
        tide_php_bg_color normal \
        tide_private_mode_bg_color normal \
        tide_pulumi_bg_color normal \
        tide_pwd_bg_color normal \
        tide_python_bg_color normal \
        tide_ruby_bg_color normal \
        tide_rustc_bg_color normal \
        tide_shlvl_bg_color normal \
        tide_status_bg_color normal \
        tide_status_bg_color_failure normal \
        tide_terraform_bg_color normal \
        tide_time_bg_color normal \
        tide_toolbox_bg_color normal \
        tide_vi_mode_bg_color_default normal \
        tide_vi_mode_bg_color_insert normal \
        tide_vi_mode_bg_color_replace normal \
        tide_vi_mode_bg_color_visual normal \
        tide_zig_bg_color normal
end

function _catppuccin_tide_apply_classic
    _catppuccin_tide_apply_lean
    set -l bg $_ctp_surface1
    _catppuccin_tide_set_pairs \
        tide_aws_bg_color $bg \
        tide_bun_bg_color $bg \
        tide_cmd_duration_bg_color $bg \
        tide_context_bg_color $bg \
        tide_crystal_bg_color $bg \
        tide_direnv_bg_color $bg \
        tide_direnv_bg_color_denied $bg \
        tide_distrobox_bg_color $bg \
        tide_docker_bg_color $bg \
        tide_elixir_bg_color $bg \
        tide_gcloud_bg_color $bg \
        tide_git_bg_color $bg \
        tide_git_bg_color_unstable $bg \
        tide_git_bg_color_urgent $bg \
        tide_go_bg_color $bg \
        tide_java_bg_color $bg \
        tide_jobs_bg_color $bg \
        tide_kubectl_bg_color $bg \
        tide_nix_shell_bg_color $bg \
        tide_node_bg_color $bg \
        tide_os_bg_color $bg \
        tide_php_bg_color $bg \
        tide_private_mode_bg_color $bg \
        tide_pulumi_bg_color $bg \
        tide_pwd_bg_color $bg \
        tide_python_bg_color $bg \
        tide_ruby_bg_color $bg \
        tide_rustc_bg_color $bg \
        tide_shlvl_bg_color $bg \
        tide_status_bg_color $bg \
        tide_status_bg_color_failure $bg \
        tide_terraform_bg_color $bg \
        tide_time_bg_color $bg \
        tide_toolbox_bg_color $bg \
        tide_vi_mode_bg_color_default $bg \
        tide_vi_mode_bg_color_insert $bg \
        tide_vi_mode_bg_color_replace $bg \
        tide_vi_mode_bg_color_visual $bg \
        tide_zig_bg_color $bg
end

function _catppuccin_tide_apply_rainbow -a variant
    set -l fg $_ctp_base
    test "$variant" = latte && set fg $_ctp_text
    set -l bg_map \
        tide_aws_bg_color $tide_aws_color \
        tide_bun_bg_color $tide_bun_color \
        tide_cmd_duration_bg_color $tide_cmd_duration_color \
        tide_context_bg_color $tide_context_color_default \
        tide_crystal_bg_color $tide_crystal_color \
        tide_direnv_bg_color $tide_direnv_color \
        tide_direnv_bg_color_denied $tide_direnv_color_denied \
        tide_distrobox_bg_color $tide_distrobox_color \
        tide_docker_bg_color $tide_docker_color \
        tide_elixir_bg_color $tide_elixir_color \
        tide_gcloud_bg_color $tide_gcloud_color \
        tide_git_bg_color $tide_git_color_branch \
        tide_git_bg_color_unstable $tide_git_color_dirty \
        tide_git_bg_color_urgent $tide_git_color_conflicted \
        tide_go_bg_color $tide_go_color \
        tide_java_bg_color $tide_java_color \
        tide_jobs_bg_color $tide_jobs_color \
        tide_kubectl_bg_color $tide_kubectl_color \
        tide_nix_shell_bg_color $tide_nix_shell_color \
        tide_node_bg_color $tide_node_color \
        tide_php_bg_color $tide_php_color \
        tide_private_mode_bg_color $tide_private_mode_color \
        tide_pulumi_bg_color $tide_pulumi_color \
        tide_pwd_bg_color $tide_pwd_color_dirs \
        tide_python_bg_color $tide_python_color \
        tide_ruby_bg_color $tide_ruby_color \
        tide_rustc_bg_color $tide_rustc_color \
        tide_shlvl_bg_color $tide_shlvl_color \
        tide_status_bg_color $tide_status_color \
        tide_status_bg_color_failure $tide_status_color_failure \
        tide_terraform_bg_color $tide_terraform_color \
        tide_time_bg_color $tide_time_color \
        tide_toolbox_bg_color $tide_toolbox_color \
        tide_vi_mode_bg_color_default $tide_vi_mode_color_default \
        tide_vi_mode_bg_color_insert $tide_vi_mode_color_insert \
        tide_vi_mode_bg_color_replace $tide_vi_mode_color_replace \
        tide_vi_mode_bg_color_visual $tide_vi_mode_color_visual \
        tide_zig_bg_color $tide_zig_color

    _catppuccin_tide_set_pairs $bg_map

    _catppuccin_tide_set_pairs \
        tide_aws_color $fg \
        tide_bun_color $fg \
        tide_cmd_duration_color $fg \
        tide_context_color_default $fg \
        tide_context_color_root $fg \
        tide_context_color_ssh $fg \
        tide_crystal_color $fg \
        tide_direnv_color $fg \
        tide_direnv_color_denied $fg \
        tide_distrobox_color $fg \
        tide_docker_color $fg \
        tide_elixir_color $fg \
        tide_gcloud_color $fg \
        tide_git_color_branch $fg \
        tide_git_color_conflicted $fg \
        tide_git_color_dirty $fg \
        tide_git_color_operation $fg \
        tide_git_color_staged $fg \
        tide_git_color_stash $fg \
        tide_git_color_untracked $fg \
        tide_git_color_upstream $fg \
        tide_go_color $fg \
        tide_java_color $fg \
        tide_jobs_color $fg \
        tide_kubectl_color $fg \
        tide_nix_shell_color $fg \
        tide_node_color $fg \
        tide_php_color $fg \
        tide_private_mode_color $fg \
        tide_pulumi_color $fg \
        tide_pwd_color_anchors $fg \
        tide_pwd_color_dirs $fg \
        tide_pwd_color_truncated_dirs $fg \
        tide_python_color $fg \
        tide_ruby_color $fg \
        tide_rustc_color $fg \
        tide_shlvl_color $fg \
        tide_status_color $fg \
        tide_status_color_failure $fg \
        tide_terraform_color $fg \
        tide_time_color $fg \
        tide_toolbox_color $fg \
        tide_vi_mode_color_default $fg \
        tide_vi_mode_color_insert $fg \
        tide_vi_mode_color_replace $fg \
        tide_vi_mode_color_visual $fg \
        tide_zig_color $fg
end

function catppuccin_tide --description "Apply Catppuccin theme variant for Tide"
    set -l variant $argv[1]
    test -z "$variant" && set variant mocha
    set -l style $argv[2]
    test -z "$style" && set style lean

    switch $variant
        case latte frappe macchiato mocha
            _catppuccin_tide_palette $variant
        case '*'
            echo "catppuccin-tide: unknown variant '$variant' (use latte, frappe, macchiato, or mocha)" >&2
            return 1
    end

    _catppuccin_tide_apply_colors

    switch $style
        case lean
            _catppuccin_tide_apply_lean
        case classic
            _catppuccin_tide_apply_classic
        case rainbow
            _catppuccin_tide_apply_rainbow $variant
        case '*'
            echo "catppuccin-tide: unknown style '$style' (use lean, classic, or rainbow)" >&2
            return 1
    end
end