#!/usr/bin/env bash
# Link shared AI skills/agents from ~/.dotfiles/ai into Cursor / Claude / OpenCode.
# Usage:
#   source ~/.dotfiles/ai/setup.sh && setup_ai_tools
#   sre_tools -A

function setup_ai_tools() {
    local ai_root="${__dotfiles_dir__:-${HOME}/.dotfiles}/ai"
    local skills_src="${ai_root}/skills"
    local agents_src="${ai_root}/agents"
    local opencode_src="${ai_root}/opencode"
    local cursor_skills="${HOME}/.cursor/skills"
    local claude_skills="${HOME}/.claude/skills"
    local opencode_live="${HOME}/.config/opencode"

    mkdir -p "${skills_src}" "${agents_src}" "${cursor_skills}"

    echo -e "${CYAN:-}Configuring AI skills/agents from ${ai_root}${NC:-}"

    __ai_migrate_cursor_skills_into_dotfiles__ "${cursor_skills}" "${skills_src}"
    __ai_seed_agents_from_opencode__ "${opencode_src}" "${agents_src}"

    local linked=0
    local skill
    for skill in "${skills_src}"/*; do
        [[ -d "${skill}" ]] || continue
        [[ -f "${skill}/SKILL.md" ]] || continue
        local name
        name="$(basename "${skill}")"
        __ai_link_dir__ "${skill}" "${cursor_skills}/${name}" && linked=$((linked + 1))
        if [[ -d "${HOME}/.claude" ]]; then
            mkdir -p "${claude_skills}"
            __ai_link_dir__ "${skill}" "${claude_skills}/${name}" || true
        fi
        echo -e "   ${GREEN:-}✓${NC:-} skill linked: ${name}"
    done

    if [[ "${linked}" -eq 0 ]]; then
        echo -e "   ${YELLOW:-}!${NC:-} no skills found under ${skills_src}"
        echo -e "     Add e.g. ${skills_src}/mattermost/SKILL.md then re-run."
    fi

    # OpenCode: prefer symlink of whole config dir pieces when live is missing
    if [[ -d "${opencode_src}" ]]; then
        mkdir -p "${opencode_live}"
        __ai_link_file_or_dir__ "${opencode_src}/opencode.jsonc" "${opencode_live}/opencode.jsonc" || true
        __ai_link_dir__ "${opencode_src}/instructions" "${opencode_live}/instructions" || true
        # Prefer shared agents/ when present; else opencode/agent
        if [[ -d "${agents_src}" ]] && compgen -G "${agents_src}/*.md" > /dev/null; then
            __ai_link_dir__ "${agents_src}" "${opencode_live}/agent" || true
            echo -e "   ${GREEN:-}✓${NC:-} opencode agents → ai/agents"
        elif [[ -d "${opencode_src}/agent" ]]; then
            __ai_link_dir__ "${opencode_src}/agent" "${opencode_live}/agent" || true
            echo -e "   ${GREEN:-}✓${NC:-} opencode agents → ai/opencode/agent"
        fi
        echo -e "   ${GREEN:-}✓${NC:-} opencode config linked (restart opencode to load)"
    fi

    echo -e "${MAGENTA:-}AI tools setup done.${NC:-}"
    echo -e "  Skills source: ${skills_src}"
    echo -e "  Cursor path:   ${cursor_skills}"
    echo -e "  Edit in the repo, commit, pull on other PCs, re-run ${GREEN:-}sre_tools -A${NC:-} if needed."

    __SRE_TOOLS_LOADED__[ai]="true" 2>/dev/null || true
}

# Copy real (non-link) Cursor skills into dotfiles once, so the repo becomes SoT.
function __ai_migrate_cursor_skills_into_dotfiles__() {
    local cursor_skills="${1}"
    local skills_src="${2}"
    [[ -d "${cursor_skills}" ]] || return 0

    local d name
    for d in "${cursor_skills}"/*; do
        [[ -d "${d}" ]] || continue
        name="$(basename "${d}")"
        # Skip if already a link/junction into skills_src
        if __ai_is_link__ "${d}"; then
            continue
        fi
        if [[ -f "${d}/SKILL.md" && ! -d "${skills_src}/${name}" ]]; then
            echo -e "   ${CYAN:-}→${NC:-} migrating ~/.cursor/skills/${name} → ai/skills/${name}"
            mkdir -p "${skills_src}/${name}"
            cp -a "${d}/." "${skills_src}/${name}/"
        fi
    done
}

function __ai_seed_agents_from_opencode__() {
    local opencode_src="${1}"
    local agents_src="${2}"
    [[ -d "${opencode_src}/agent" ]] || return 0
    if compgen -G "${agents_src}/*.md" > /dev/null; then
        return 0
    fi
    echo -e "   ${CYAN:-}→${NC:-} seeding ai/agents from ai/opencode/agent"
    mkdir -p "${agents_src}"
    cp -a "${opencode_src}/agent/." "${agents_src}/"
}

function __ai_is_link__() {
    local path="${1}"
    [[ -L "${path}" ]] && return 0
    # Windows junction / symlink: dirattr often shows <JUNCTION> via cmd
    if command -v cmd.exe >/dev/null 2>&1 || command -v cmd >/dev/null 2>&1; then
        local win
        win="$(__ai_win_path__ "${path}" 2>/dev/null)" || return 1
        cmd.exe //c "dir /AL \"${win}\" 2>nul" | grep -qi "${path##*/}" && return 0
    fi
    return 1
}

function __ai_win_path__() {
    local p="${1}"
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -w "${p}"
        return
    fi
    # Git Bash often has /c/Users/...
    if [[ "${p}" =~ ^/([a-zA-Z])/(.*)$ ]]; then
        echo "${BASH_REMATCH[1]^}:/${BASH_REMATCH[2]//\//\\}"
        return
    fi
    echo "${p}"
}

function __ai_rm_path__() {
    local path="${1}"
    [[ -e "${path}" || -L "${path}" ]] || return 0
    if __ai_is_link__ "${path}"; then
        rm -f "${path}" 2>/dev/null || rm -rf "${path}"
        return
    fi
    # Real directory — replace with link; backup once
    if [[ -d "${path}" ]]; then
        local bak="${path}.bak.$(date +%Y%m%d%H%M%S)"
        echo -e "   ${YELLOW:-}!${NC:-} replacing ${path} (backup → ${bak})"
        mv "${path}" "${bak}"
        return
    fi
    rm -f "${path}"
}

function __ai_link_dir__() {
    local src="${1}"
    local dest="${2}"
    [[ -d "${src}" ]] || return 1

    mkdir -p "$(dirname "${dest}")"

    # Already correctly linked?
    if [[ -L "${dest}" ]]; then
        local target
        target="$(readlink "${dest}" 2>/dev/null || true)"
        if [[ "${target}" == "${src}" ]]; then
            return 0
        fi
    fi

    __ai_rm_path__ "${dest}"

    if [[ "${OSTYPE}" == msys* || "${OSTYPE}" == cygwin* || "${OSTYPE}" == mingw* ]] \
        || uname -s 2>/dev/null | grep -qiE 'mingw|msys|cygwin'; then
        local wsrc wdest
        wsrc="$(__ai_win_path__ "${src}")"
        wdest="$(__ai_win_path__ "${dest}")"
        if cmd.exe //c "mklink /J \"${wdest}\" \"${wsrc}\"" >/dev/null 2>&1; then
            return 0
        fi
        # Fallback: symlink (may need Developer Mode)
        if cmd.exe //c "mklink /D \"${wdest}\" \"${wsrc}\"" >/dev/null 2>&1; then
            return 0
        fi
        echo -e "   ${RED:-}x${NC:-} failed to junction ${dest}; copying instead"
        mkdir -p "${dest}"
        cp -a "${src}/." "${dest}/"
        return 0
    fi

    ln -sfn "${src}" "${dest}"
}

function __ai_link_file_or_dir__() {
    local src="${1}"
    local dest="${2}"
    [[ -e "${src}" ]] || return 1
    if [[ -d "${src}" ]]; then
        __ai_link_dir__ "${src}" "${dest}"
        return
    fi
    mkdir -p "$(dirname "${dest}")"
    if [[ -L "${dest}" ]] || [[ -f "${dest}" ]]; then
        local target
        target="$(readlink "${dest}" 2>/dev/null || true)"
        [[ "${target}" == "${src}" ]] && return 0
        __ai_rm_path__ "${dest}"
    fi
    if [[ "${OSTYPE}" == msys* || "${OSTYPE}" == cygwin* || "${OSTYPE}" == mingw* ]] \
        || uname -s 2>/dev/null | grep -qiE 'mingw|msys|cygwin'; then
        local wsrc wdest
        wsrc="$(__ai_win_path__ "${src}")"
        wdest="$(__ai_win_path__ "${dest}")"
        if cmd.exe //c "mklink \"${wdest}\" \"${wsrc}\"" >/dev/null 2>&1; then
            return 0
        fi
        cp -a "${src}" "${dest}"
        return 0
    fi
    ln -sfn "${src}" "${dest}"
}

function myhelp_ai() {
    echo -e "${__HEADER_COLOR__:-}AI tools (dotfiles)${NC:-}"
    echo -e "  ${__COMMAND_COLOR__:-}setup_ai_tools${NC:-}   Link skills/agents into Cursor, Claude, OpenCode"
    echo -e "  ${__COMMAND_COLOR__:-}sre_tools -A${NC:-}     Same via SRE tools menu"
    echo -e "  Skills live in: ${HOME}/.dotfiles/ai/skills"
    echo -e "  Agents live in: ${HOME}/.dotfiles/ai/agents"
}
