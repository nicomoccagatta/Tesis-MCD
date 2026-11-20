"""Tecnologías frontend que se siguen sitio por sitio, agrupadas por familia.

Lista: los frameworks del relevamiento State of JS 2025 que existen en el catálogo de Wappalyzer
de HTTP Archive, las tecnologías del catálogo que implican a alguno de ellos (ej. Gatsby -> React,
o las variantes de Next.js que Wappalyzer detecta por separado: App Router y Page Router),
los frameworks anteriores presentes en la cohorte top 10k (AngularJS, Backbone.js, Knockout.js,
Polymer, Stimulus...) y WordPress, que es uno de los pares del estudio.

Familia = framework al que lleva la relación `implies` de Wappalyzer (ej. Remix implica React).
Angular y AngularJS se agrupan por nombre; sin `implies` hacia un framework de la lista, "Otros".
El orden de FAMILIAS es el orden de los colores en la bitácora.
"""

FAMILIAS = ["React", "jQuery", "Vue", "WordPress", "Svelte", "Angular", "Otros"]

TECNOLOGIAS_FRONTEND = {
    "React": "React", "Next.js": "React", "Next.js App Router": "React",
    "Next.js Page Router SSG": "React", "Next.js Page Router SSR": "React", "Remix": "React", "React Router": "React",
    "Gatsby": "React", "Hydrogen": "React", "Docusaurus": "React", "RedwoodJS": "React",
    "jQuery": "jQuery",
    "Vue.js": "Vue", "Nuxt.js": "Vue", "Gridsome": "Vue", "VitePress": "Vue",
    "WordPress": "WordPress",
    "Svelte": "Svelte", "SvelteKit": "Svelte", "Sapper": "Svelte",
    "Angular": "Angular", "AngularJS": "Angular",
    "Astro": "Otros", "Qwik": "Otros", "Preact": "Otros", "lit-html": "Otros",
    "lit-element": "Otros", "Alpine.js": "Otros", "Htmx": "Otros", "Ember.js": "Otros",
    "Backbone.js": "Otros", "Stimulus": "Otros", "Inertia.js": "Otros", "Quasar": "Otros",
    "Meteor": "Otros", "Stencil": "Otros", "Aurelia": "Otros", "Knockout.js": "Otros",
    "Polymer": "Otros", "SolidJS": "Otros", "SolidStart": "Otros", "TanStack Start": "Otros",
    "Fresh": "Otros", "Elm": "Otros", "Eleventy": "Otros",
}

# Framework principal de un sitio-mes: el primer grupo presente, en este orden. Las tecnologías que
# implican un framework cuentan como ese framework; jQuery solo es el principal si no hay otro.
GRUPOS_PRINCIPAL = {
    "Next.js": {"Next.js", "Next.js App Router", "Next.js Page Router SSG", "Next.js Page Router SSR"},
    "React": {"React", "Remix", "React Router", "Gatsby", "Hydrogen", "Docusaurus", "RedwoodJS"},
    "Nuxt": {"Nuxt.js"},
    "Vue": {"Vue.js", "Gridsome", "VitePress"},
    "Angular": {"Angular", "AngularJS"},
    "Svelte": {"Svelte", "SvelteKit", "Sapper"},
    "Otros frameworks": {"Astro", "Qwik", "Preact", "lit-html", "lit-element", "Alpine.js", "Htmx", "Ember.js",
                         "Backbone.js", "Stimulus", "Inertia.js", "Quasar", "Meteor", "Stencil", "Aurelia",
                         "Knockout.js", "Polymer", "SolidJS", "SolidStart", "TanStack Start", "Fresh", "Elm",
                         "Eleventy"},
    "jQuery": {"jQuery"},
}
SIN_FRAMEWORK = "Sin framework"


def framework_principal(tecnologias):
    return next((g for g, miembros in GRUPOS_PRINCIPAL.items() if tecnologias & miembros), SIN_FRAMEWORK)


# Campos de la custom metric "aurora" de HTTP Archive (custom_metrics.other.aurora) que completan la
# detección de Wappalyzer: presencia y versión de cada framework que aurora mide. La versión de React
# sale del hook de React DevTools (último renderer registrado): solo las versiones mayores 16-19 son de
# react-dom; otra versión indica otro renderer (ej. @react-three/fiber 9.x) y React con versión desconocida.
AURORA_CAMPOS = {
    "React": "aurora_react", "Next.js": "aurora_next", "Nuxt.js": "aurora_nuxt",
    "Angular": "aurora_angular", "Svelte": "aurora_svelte",
}
AURORA_VERSION_VUE = "aurora_nuxt_vue"  # versión de Vue que usa Nuxt: completa la de Vue.js
REACT_DOM_MAYORES = range(16, 20)
