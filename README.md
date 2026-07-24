# 🌸 SKINCARE MO - Sistema de Reservación de Citas en Tiempo Real

Bienvenido al repositorio oficial de **SKINCARE MO** (Terapia Física, Salud y Bienestar). 

Esta plataforma web profesional permite gestionar reservaciones de citas en tiempo real con integración de backend en **Supabase** y fallback síncrono ultra rápido.

---

## 🚀 Características Principales

1. **Selección Dual de Tratamientos:**
   - Permite seleccionar hasta **2 servicios** por cita.
   - Cálculo síncrono del subtotal, total y **duración combinada** para bloquear el tiempo requerido.

2. **Algoritmo Inteligente de Disponibilidad de Horarios:**
   - Horario habitual: **09:00 a 18:00 hrs (Lunes a Sábado)**.
   - Validación automática de **mínimo 2 horas de anticipación**.
   - Verificación instantánea contra citas existentes y bloqueos de agenda.

3. **Cupones de Descuento con Rango de Vigencias:**
   - Soporta porcentaje (`%`) o monto fijo (`$`).
   - Validación visual en tiempo real (*Vigente*, *Próximamente*, *Caducó*).

4. **Ficha de Depósito Descargable & WhatsApp:**
   - Genera una ficha visual elegante con los datos bancarios de **OPENBANK MX** (CLABE: `646180401617525026`, Titular: `Mariela Olvera Quintana`) y monto de anticipo obligatorio (**$150.00 MXN**).
   - Botón negro compacto **Descargar Ficha** (descarga PNG con `html2canvas`) y botón verde **WhatsApp** prellenado listo para enviar a **+52 777 214 8451**.

5. **Panel Administrativo:**
   - Gestión en tiempo real de citas, cupones, bloqueos de agenda y catálogo de servicios.

---

## 🛠️ Instrucciones de Configuración en Supabase

1. Abre tu consola en [Supabase.com](https://supabase.com).
2. Ve a la pestaña **SQL Editor** y ejecuta el contenido completo del archivo [`schema.sql`](file:///C:/Users/irvin/.gemini/antigravity/scratch/skincare-mo-app/schema.sql).
3. Copia tu `SUPABASE_URL` y tu `SUPABASE_ANON_KEY` desde la sección *Settings > API*.
4. Abre `index.html` en tu navegador, haz clic en el botón **Supabase** de la barra superior e ingresa tus credenciales.

---

## 📁 Archivos del Proyecto

- [`index.html`](file:///C:/Users/irvin/.gemini/antigravity/scratch/skincare-mo-app/index.html): Aplicación Web completa e integral.
- [`schema.sql`](file:///C:/Users/irvin/.gemini/antigravity/scratch/skincare-mo-app/schema.sql): Script de base de datos listo para ejecutar en Supabase.
