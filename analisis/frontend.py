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
