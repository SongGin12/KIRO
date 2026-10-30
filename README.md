# KIRO

> «Tu mundo organizado, con un compañero a tu lado».

**KIRO** es un compañero digital interactivo y colaborativo: un personaje con identidad visual y personalidad propia que comparte con el usuario un entorno de información, lo acompaña en sus actividades personales y participa en la organización de sus proyectos y tareas.

> **Documento conceptual.** Este README describe la propuesta, el alcance previsto y los objetivos académicos del proyecto. No constituye evidencia de funcionalidades implementadas.

---

## Índice

- [1. Presentación](#1-presentación)
- [2. El problema](#2-el-problema)
- [3. Objetivo general](#3-objetivo-general)
- [4. Los tres pilares de KIRO](#4-los-tres-pilares-de-kiro)
- [5. Módulos funcionales](#5-módulos-funcionales)
- [6. Características diferenciadoras](#6-características-diferenciadoras)
- [7. Apariencia y personalidad](#7-apariencia-y-personalidad)
- [8. Enfoque académico: Bases de Datos II](#8-enfoque-académico-bases-de-datos-ii)
- [9. Arquitectura y seguridad conceptual](#9-arquitectura-y-seguridad-conceptual)
- [10. Reglas de negocio principales](#10-reglas-de-negocio-principales)
- [11. Alcance y limitaciones](#11-alcance-y-limitaciones)
- [12. Estado actual del proyecto](#12-estado-actual-del-proyecto)
- [13. Autoría](#13-autoría)

---

## 1. Presentación

### Qué es KIRO

KIRO es un **compañero digital interactivo y colaborativo**. Combina tres ideas en una sola experiencia:

1. Una **identidad propia**: un personaje original, cercano y expresivo, con una personalidad configurable.
2. Un **entorno de trabajo compartido**: agenda, notas, proyectos, recursos y memoria accesibles desde una misma interfaz.
3. Una **capacidad de colaboración concreta**: el usuario puede delegar operaciones sobre la información que ambos comparten, sin perder el control ni la trazabilidad.

KIRO no sustituye al usuario: lo acompaña. Puede ayudarle a recordar, ordenar, relacionar y ejecutar acciones definidas, mientras el usuario conserva la decisión final sobre su información.

### Qué no es KIRO

Para evitar ambigüedades, conviene delimitar el concepto:

- **No es un asistente virtual convencional.** No se centra en comandos aislados ni en responder preguntas generales.
- **No es un clon de Alexa.** No está orientado al control de dispositivos, electrodomésticos o domótica.
- **No es un chatbot con avatar.** El personaje no es un adorno: forma parte de la identidad del producto y de la experiencia de interacción.
- **No es un producto comercial terminado.** Es una propuesta académica en etapa inicial de planificación.

---

## 2. El problema

La información personal y de trabajo suele estar dispersa entre aplicaciones, notas sueltas, calendarios, mensajes y documentos. Esta dispersión produce varios problemas frecuentes:

- **Pérdida de contexto:** se registran datos, pero no siempre se recuperan las decisiones, los motivos o el estado de un proyecto.
- **Duplicación y desorden:** la misma información vive en varios lugares y pierde consistencia.
- **Falta de continuidad:** las herramientas no acompañan al usuario ni relacionan lo personal con lo laboral o académico.
- **Poca trazabilidad:** no queda claro qué se cambió, cuándo ni por qué.
- **Interfaces frías:** la organización personal puede resultar tediosa cuando la herramienta no transmite cercanía ni comprensión del contexto.

KIRO propone un enfoque distinto: **un único entorno compartido**, con un compañero que ayuda a mantenerlo ordenado y que puede actuar sobre él de forma controlada.

---

## 3. Objetivo general

Diseñar y desarrollar, como proyecto académico individual, la propuesta conceptual y el prototipo funcional de **KIRO**, un compañero digital interactivo y colaborativo que permita al usuario organizar información personal y de trabajo, desarrollar proyectos y delegar operaciones concretas sobre un entorno de datos compartido, seguro y trazable.

### Objetivos específicos previstos

- Definir la identidad, la personalidad y las reglas de interacción del compañero digital.
- Modelar un entorno de información que integre agenda, notas, proyectos, recursos y memoria.
- Diseñar una capa de operaciones controladas que permita a KIRO actuar sin acceso libre a la base de datos.
- Aplicar los contenidos de Bases de Datos II en el diseño, la implementación y la validación del núcleo de persistencia.
- Documentar el alcance, las limitaciones y el estado real del proyecto con transparencia.

> **Alcance realista.** KIRO es un proyecto individual desarrollado en el marco de una asignatura. Por ello se plantea como un **MVP académico**: un subconjunto coherente y demostrable de la visión completa, no un producto comercial con todas sus funciones.

---

## 4. Los tres pilares de KIRO

### A. Compañero personal

El primer pilar define la relación entre el usuario y KIRO. No se trata solo de una interfaz, sino de una presencia digital con identidad propia.

- Personaje 3D original, tierno y expresivo.
- Personalidad y estilos de comunicación configurables.
- Interacción mediante texto y voz.
- Memoria configurable y controlada por el usuario.
- Expresiones visuales y reacciones durante las interacciones.
- Comunicación cercana, respetuosa y contextual.

La voz se entiende aquí como **un medio de comunicación**, no como el propósito del producto. KIRO puede escuchar y hablar, pero su valor principal está en acompañar y colaborar, no en ejecutar comandos por voz.

### B. Compañero colaborativo

El segundo pilar describe cómo KIRO participa en el trabajo intelectual y organizativo del usuario.

- Ayudar a desarrollar y organizar ideas.
- Participar en la planificación de proyectos.
- Relacionar información de distintas áreas.
- Recuperar decisiones y datos previamente registrados.
- Ayudar a reorganizar actividades y prioridades.
- Proponer acciones según el contexto disponible.

KIRO no decide por el usuario. Propone, sugiere y ejecuta cuando recibe autorización, manteniendo siempre visible el contexto de lo que ocurre.

### C. Gestión del entorno digital

El tercer pilar convierte la conversación en acciones concretas sobre la información del usuario.

- Agenda y administración de citas.
- Registro y edición de notas e ideas.
- Gestión de proyectos y actividades.
- Biblioteca de documentos, enlaces y recursos.
- Memoria e historial de operaciones.
- Ejecución de operaciones mediante herramientas controladas.

Los tres pilares se refuerzan entre sí: la identidad hace cercana la interacción, la colaboración aporta contexto y la gestión del entorno produce resultados verificables.

---

## 5. Módulos funcionales

### Clasificación del estado

Cada módulo se presenta con un estado explícito para evitar confusiones entre la visión del producto y lo realmente construido.

| Estado | Significado |
|---|---|
| **Propuesto** | Definido a nivel conceptual; no implementado. |
| **En diseño** | Se está trabajando en su modelo o especificación; aún no es funcional. |
| **Implementado** | Existe y puede demostrarse con evidencia en el repositorio. |

> **Estado actual:** todos los módulos se encuentran en estado **Propuesto**. No hay funcionalidades implementadas que puedan presentarse como terminadas.

### Resumen de módulos

| # | Módulo | Propósito | Prioridad prevista | Estado |
|---|---|---|---|---|
| 1 | Compañero digital e interacción | Dar identidad, voz y presencia al compañero. | Alta | Propuesto |
| 2 | Agenda y citas | Organizar compromisos y disponibilidad. | Alta | Propuesto |
| 3 | Notas e ideas | Registrar y recuperar información breve. | Alta | Propuesto |
| 4 | Proyectos y actividades | Planificar y dar seguimiento al trabajo. | Alta | Propuesto |
| 5 | Biblioteca de recursos | Centralizar documentos, enlaces y referencias. | Media | Propuesto |
| 6 | Memoria e historial | Conservar contexto y trazabilidad de operaciones. | Alta | Propuesto |
| 7 | Colaboración y operaciones | Permitir que KIRO actúe mediante herramientas controladas. | Media | Propuesto |

### 5.1. Compañero digital e interacción

- Presentación visual del personaje y estados de ánimo de diseño (alegría, curiosidad, atención, pensamiento, descanso).
- Interacción por texto y, como medio complementario, por voz.
- Configuración de personalidad y estilo de comunicación.
- Respuestas contextualizadas según la información disponible y los permisos del usuario.
- Controles de memoria: activar, desactivar, revisar y eliminar recuerdos.
- Indicadores claros de cuándo KIRO está escuchando, procesando, proponiendo o ejecutando una operación.

### 5.2. Agenda y citas

- Registro de citas con fecha, hora, duración, lugar y descripción.
- Edición, reprogramación y cancelación de citas.
- Consulta por día, semana o rango de fechas.
- Detección de conflictos de horario.
- Recordatorios y avisos de próximos compromisos.
- Relación de citas con proyectos, notas o contactos cuando corresponda.

### 5.3. Notas e ideas

- Creación de notas libres y de ideas rápidas.
- Edición, etiquetado y búsqueda por texto.
- Organización por temas, proyectos o fechas.
- Dictado de ideas para que KIRO las registre, con confirmación previa.
- Recuperación de notas relacionadas con el contexto actual.

### 5.4. Proyectos y actividades

- Creación de proyectos con objetivo, estado y fechas relevantes.
- Desglose en actividades o tareas.
- Asignación de prioridades y estados de avance.
- Reorganización de actividades según plazos y dependencias.
- Vista de resumen del proyecto y de sus próximos pasos.
- Registro de decisiones importantes para conservar el contexto.

### 5.5. Biblioteca de recursos

- Registro de documentos, enlaces, referencias y materiales de apoyo.
- Clasificación por proyecto, tema o tipo de recurso.
- Búsqueda y recuperación de recursos previamente registrados.
- Asociación de recursos con notas, actividades o decisiones.
- Metadatos básicos: título, descripción, origen y fecha de incorporación.

### 5.6. Memoria e historial

- Memoria de preferencias, decisiones y contexto autorizado por el usuario.
- Historial de operaciones realizadas por el usuario y por KIRO.
- Consulta de cambios recientes y recuperación de decisiones anteriores.
- Posibilidad de revocar recuerdos o desactivar su uso.
- Separación clara entre información recordada, información consultada e información modificada.

### 5.7. Colaboración y ejecución de operaciones

- Catálogo de herramientas y operaciones permitidas.
- Validación de datos antes de ejecutar cualquier cambio.
- Confirmación del usuario en operaciones sensibles o destructivas.
- Ejecución de operaciones sobre los mismos registros que utiliza el usuario.
- Registro de cada operación con autor, momento y resultado.
- Respuestas explicativas cuando una operación no puede realizarse.

---

## 6. Características diferenciadoras

La diferencia central de KIRO no es la voz ni la apariencia, sino la **relación entre el compañero y el entorno de información**.

| Aspecto | Asistente convencional | KIRO |
|---|---|---|
| Rol principal | Responder comandos o preguntas. | Acompañar y colaborar en la organización. |
| Relación con los datos | Consultas aisladas. | Entorno compartido y persistente. |
| Identidad | Genérica o intercambiable. | Personaje original con personalidad propia. |
| Interacción | Principalmente por voz. | Texto y voz, con contexto y continuidad. |
| Ejecución de acciones | Comandos directos. | Operaciones controladas, validadas y trazables. |
| Memoria | Limitada o implícita. | Configurable y controlada por el usuario. |

### Un mismo entorno, dos formas de trabajar

El usuario puede trabajar directamente desde la interfaz o pedirle a KIRO que realice operaciones sobre los mismos registros. Ambos caminos conducen a la misma información y respetan las mismas reglas.

Algunos ejemplos:

- El usuario puede editar una cita desde la agenda o pedir a KIRO que la reprograme.
- Puede escribir una nota directamente o dictarle una idea al compañero para que la registre.
- Puede organizar un proyecto manualmente o pedir ayuda para reorganizar sus actividades.
- Puede consultar recuerdos autorizados y recuperar decisiones anteriores.

### Lo que KIRO no pretende ser

- No es un centro de control del hogar.
- No es un reproductor musical ni un asistente de entretenimiento.
- No es un modelo de inteligencia artificial entrenado desde cero.
- No es un robot físico dentro del alcance de este proyecto.

---

## 7. Apariencia y personalidad

### Identidad visual propuesta

La identidad visual de KIRO es **tierna, amigable y futurista**. Busca transmitir cercanía sin perder una estética tecnológica y cuidada.

Características visuales previstas:

- Robot pequeño, original y estilizado.
- Cuerpo compacto y redondeado.
- Apariencia blanco perlado.
- Detalles verde menta y dorados.
- Ojos expresivos.
- Animaciones de alegría, curiosidad, atención, pensamiento y descanso.

El diseño debe ser **original**. No se copiarán personajes protegidos de películas, series o franquicias. Cualquier referencia visual servirá únicamente como inspiración de tono, nunca como reproducción.

### Personalidad

La personalidad de KIRO debe transmitir:

- **Cercanía:** un trato amable y respetuoso.
- **Curiosidad:** interés por comprender el contexto del usuario.
- **Organización:** preferencia por la claridad y el orden.
- **Respeto:** límites claros, sin invadir la privacidad ni tomar decisiones por el usuario.

Los estilos de comunicación podrán ajustarse según las preferencias del usuario: más breve o más detallado, más formal o más cercano, con mayor o menor iniciativa.

### Expresiones y transparencia

Las expresiones visuales de KIRO son **elementos de diseño de interacción**. No representan emociones reales ni implican conciencia, intenciones propias o experiencia subjetiva. Su función es comunicar estado, atención y contexto de forma comprensible y agradable.

---

## 8. Enfoque académico: Bases de Datos II

### Contexto

KIRO es un **proyecto individual** para la asignatura **Bases de Datos II** de la **Universidad de Los Andes (Unandes)**. El núcleo de persistencia y gestión de la información será **MySQL**.

El proyecto busca que la organización del compañero digital no sea solo una idea de producto, sino una oportunidad para aplicar de forma coherente los contenidos de la asignatura: modelado, consultas, seguridad, automatización, transacciones y recuperación.

### Competencias previstas

Las siguientes competencias se plantean como **objetivos académicos previstos**. No todas se implementarán necesariamente: la selección final dependerá del alcance, el tiempo disponible y las prioridades del proyecto.

| Competencia | Aplicación prevista en KIRO |
|---|---|
| Modelo entidad-relación y normalización | Diseñar entidades como usuario, cita, nota, proyecto, actividad, recurso, operación y memoria, aplicando normalización hasta una forma razonable para el alcance. |
| Consultas SQL avanzadas | Resolver búsquedas, filtros por fecha y estado, y consultas de recuperación de información. |
| JOIN, subconsultas y agregaciones | Relacionar información entre módulos y obtener resúmenes, conteos y estados consolidados. |
| Vistas e índices | Crear vistas para agenda, proyectos y actividad reciente, e índices para las consultas más frecuentes. |
| EXPLAIN | Analizar el plan de ejecución de consultas representativas y justificar mejoras. |
| Procedimientos almacenados | Encapsular operaciones como registrar una cita, reprogramarla o cerrar una actividad. |
| Funciones y triggers | Validar datos, mantener marcas de tiempo y alimentar registros de auditoría. |
| Transacciones | Asegurar operaciones que afectan varias tablas, por ejemplo al mover una actividad entre proyectos. |
| Permisos y seguridad | Definir usuarios de base de datos con privilegios mínimos y separar responsabilidades. |
| Auditoría | Registrar operaciones relevantes con autor, fecha, acción y resultado. |
| Respaldos y recuperación | Documentar una estrategia básica de respaldo y restauración de la base de datos. |

### Honestidad académica

Este documento distingue entre **lo propuesto** y **lo implementado**. No se declararán tablas, consultas, procedimientos, métricas ni resultados que no existan en el repositorio o que no puedan demostrarse. El avance se documentará de forma incremental, con evidencia verificable.

---

## 9. Arquitectura y seguridad conceptual

### Principio central

KIRO **no tendrá acceso libre a MySQL** ni ejecutará consultas arbitrarias. Toda interacción con la base de datos pasará por una capa de operaciones definidas por el sistema.

```text
Usuario
  │  texto / voz / interfaz
  ▼
Compañero digital (identidad, contexto y diálogo)
  ▼
Capa de operaciones controladas
  │  validación · permisos · confirmación · trazabilidad
  ▼
MySQL
  │  persistencia · integridad · auditoría
  ▼
Historial de operaciones
```

### Componentes conceptuales

1. **Interfaz de usuario:** permite trabajar directamente con agenda, notas, proyectos, recursos y memoria.
2. **Compañero digital:** interpreta la solicitud, mantiene el contexto autorizado y propone una acción.
3. **Capa de operaciones:** traduce la intención en una herramienta permitida, valida los datos y verifica permisos.
4. **Confirmación:** solicita autorización cuando la operación es sensible, irreversible o afecta varios registros.
5. **Persistencia:** MySQL almacena la información y aplica restricciones de integridad.
6. **Trazabilidad:** se conserva un registro de operaciones relevantes para auditoría y recuperación de contexto.

### Reglas de seguridad previstas

- El compañero no genera SQL directo ni recibe credenciales de base de datos.
- Cada operación pertenece a un catálogo explícito de herramientas.
- Los datos se validan antes de llegar a la base de datos.
- Las operaciones destructivas requieren confirmación del usuario.
- El acceso a la información respeta los permisos y la configuración de memoria.
- Las operaciones importantes conservan trazabilidad.
- Los errores se comunican de forma comprensible, sin exponer detalles internos innecesarios.

### Relación con hardware físico

La arquitectura podrá contemplar en el futuro una conexión con hardware físico, pero **el robot físico no forma parte del alcance de este proyecto académico**. Cualquier mención a hardware se limita a una posibilidad de evolución, no a un entregable.

---

## 10. Reglas de negocio principales

Las siguientes reglas orientan el diseño funcional y la futura implementación. Son una propuesta, no una descripción de componentes ya construidos.

| ID | Regla |
|---|---|
| RN-01 | El usuario y KIRO trabajan sobre los mismos registros; no existen copias paralelas de la información. |
| RN-02 | Toda operación de KIRO pasa por una herramienta definida y validada; no hay acceso directo a la base de datos. |
| RN-03 | Los datos obligatorios se validan antes de registrar o modificar cualquier entidad. |
| RN-04 | Las operaciones sensibles o destructivas requieren confirmación explícita del usuario. |
| RN-05 | Toda operación relevante queda registrada con autor, fecha, acción y resultado. |
| RN-06 | La memoria es configurable: el usuario puede revisar, desactivar o eliminar recuerdos autorizados. |
| RN-07 | Una cita no puede ocupar un horario ya reservado, salvo que el usuario resuelva el conflicto. |
| RN-08 | Una actividad pertenece a un proyecto o queda registrada como actividad independiente, nunca en ambos estados a la vez. |
| RN-09 | Los registros eliminados de forma lógica pueden recuperarse; la eliminación definitiva es una acción excepcional y confirmada. |
| RN-10 | Las integraciones externas son opcionales y no pueden desplazar el propósito principal de organización y colaboración. |

---

## 11. Alcance y limitaciones

### Incluido en el alcance previsto

- Propuesta conceptual y identidad del compañero digital.
- Diseño de la experiencia de interacción por texto y voz.
- Modelo de información para agenda, notas, proyectos, recursos y memoria.
- Capa de operaciones controladas con validación, permisos y trazabilidad.
- Núcleo de persistencia en MySQL, con los elementos de Bases de Datos II que el alcance permita.
- Documentación del estado real del proyecto y de sus decisiones de diseño.

### Fuera del alcance

- Control de electrodomésticos.
- Automatización doméstica.
- Reproducción musical como función central.
- Entrenamiento de modelos propios de inteligencia artificial.
- Construcción de hardware físico.
- Afirmar conciencia o emociones reales en el compañero.
- Sustituir la decisión del usuario sobre su propia información.

### Mejoras futuras opcionales

Solo si no desplazan el propósito principal, podrían considerarse mejoras como integraciones externas (por ejemplo, servicios de música o calendarios), una versión más elaborada del personaje 3D o una exploración de hardware. Ninguna de estas mejoras forma parte del compromiso académico actual.

### Limitaciones reales

- Es un proyecto individual con tiempo y recursos acotados.
- No todas las competencias de Bases de Datos II se implementarán necesariamente.
- El personaje 3D y la interacción por voz pueden requerir prototipos simplificados.
- La calidad de las sugerencias del compañero dependerá del contexto disponible y de las reglas definidas, no de un modelo entrenado desde cero.
- La seguridad se diseñará de forma proporcional al alcance académico, no como una auditoría de nivel producción.

---

## 12. Estado actual del proyecto

**Estado general:** etapa inicial de planificación.

| Elemento | Estado |
|---|---|
| Documento conceptual (este README) | En elaboración |
| Identidad y personalidad de KIRO | Definidas a nivel conceptual |
| Diseño de la base de datos | No iniciado |
| Modelo entidad-relación | No iniciado |
| Interfaz de usuario | No iniciada |
| Personaje 3D | No iniciado |
| Módulos funcionales | No implementados |
| Pruebas y validación | No iniciadas |
| Integraciones externas | Fuera del alcance actual |

### Próximos pasos previstos

1. Delimitar el MVP académico y priorizar los módulos viables.
2. Diseñar el modelo entidad-relación y las reglas de integridad.
3. Definir el catálogo de operaciones controladas.
4. Diseñar la interfaz mínima de agenda, notas y proyectos.
5. Implementar el núcleo de persistencia y documentar la evidencia.
6. Validar consultas, transacciones y mecanismos de seguridad.

> Este README se actualizará a medida que exista evidencia verificable. Hasta entonces, las funcionalidades descritas deben interpretarse como propuestas.

---

## 13. Autoría

| Campo | Valor |
|---|---|
| **Autor** | Poma Jurado Cruz Cohen |
| **Institución** | Universidad de Los Andes (Unandes) |
| **Asignatura** | Bases de Datos II |
| **Tipo de proyecto** | Individual |
| **Estado** | Etapa inicial de planificación |

> **Nota de edición:** el nombre del autor se mantiene como marcador editable. Puede actualizarse si la autoría del proyecto cambia.

---

<p align="center">
  <strong>KIRO</strong><br>
  Tu mundo organizado, con un compañero a tu lado.
</p>
