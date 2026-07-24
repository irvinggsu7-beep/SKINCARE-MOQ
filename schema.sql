-- ====================================================================
-- SCRIPT DE BASE DE DATOS PARA SUPABASE - SKINCARE MO SPA & FISIOTERAPIA
-- ====================================================================

-- 1. Tabla de Servicios
CREATE TABLE IF NOT EXISTS public.servicios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    duracion_min INT NOT NULL CHECK (duracion_min > 0),
    precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
    activo BOOLEAN DEFAULT true,
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabla de Cupones con Rango de Vigencias
CREATE TABLE IF NOT EXISTS public.cupones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('porcentaje', 'fijo')),
    valor DECIMAL(10, 2) NOT NULL CHECK (valor > 0),
    fecha_inicio DATE NOT NULL,
    fecha_expiracion DATE NOT NULL,
    activo BOOLEAN DEFAULT true,
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_fechas CHECK (fecha_expiracion >= fecha_inicio)
);

-- 3. Tabla de Bloqueos de Agenda
CREATE TABLE IF NOT EXISTS public.bloqueos_agenda (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    motivo TEXT,
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_horas_bloqueo CHECK (hora_fin > hora_inicio)
);

-- 4. Tabla de Citas Reservadas
CREATE TABLE IF NOT EXISTS public.citas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    codigo_cita VARCHAR(20) UNIQUE NOT NULL,
    cliente_nombre VARCHAR(150) NOT NULL,
    cliente_telefono VARCHAR(20) NOT NULL,
    cliente_email VARCHAR(150),
    servicios_ids JSONB NOT NULL, -- Array de IDs de servicios seleccionados (máx 2)
    servicios_nombres TEXT NOT NULL,
    total_duracion_min INT NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    cupon_codigo VARCHAR(50),
    descuento DECIMAL(10, 2) DEFAULT 0.00,
    total DECIMAL(10, 2) NOT NULL,
    monto_anticipo DECIMAL(10, 2) DEFAULT 150.00,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    limite_pago TIMESTAMP WITH TIME ZONE NOT NULL, -- Límite de pago (2h o 30m)
    tipo_tolerancia VARCHAR(20) DEFAULT 'regular', -- 'regular' (2h) o 'pronta' (30m)
    estado VARCHAR(30) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'confirmada', 'cancelada', 'completada')),
    notas TEXT,
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Tabla de Configuración del Negocio
CREATE TABLE IF NOT EXISTS public.configuracion (
    clave VARCHAR(50) PRIMARY KEY,
    valor JSONB NOT NULL,
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ====================================================================
-- DATOS SEMILLA INICIALES (SEED DATA)
-- ====================================================================

-- Insertar los 4 Servicios Semilla Oficiales
INSERT INTO public.servicios (nombre, descripcion, duracion_min, precio, activo)
VALUES 
    ('Facial Glow Premium', 'Limpieza profunda con punta de diamante, mascarilla hidroplástica de rosas y sueros hidratantes.', 60, 850.00, true),
    ('Masaje Relajante Pink Lotus', 'Masaje de cuerpo completo con aceites esenciales de loto y rosas.', 60, 900.00, true),
    ('Pedicura Spa Estética', 'Cuidado especializado de pies, exfoliación con sales rosas y esmaltado.', 60, 600.00, true),
    ('Depilación Láser Diodo', 'Sesión de depilación médica rápida, indolora y efectiva.', 30, 450.00, true)
ON CONFLICT DO NOTHING;

-- Insertar Configuración Básica del Negocio con Horario Operativo y Contraseña Admin por defecto ('0000')
INSERT INTO public.configuracion (clave, valor)
VALUES 
    ('datos_negocio', '{
        "nombre": "SKINCARE MO",
        "slogan": "Terapia Física, Salud y Bienestar",
        "hero_msg": "Tu salud y bienestar merecen la mejor atención.",
        "whatsapp": "527772148451",
        "banco": "OPENBANK MX",
        "clabe": "646180401617525026",
        "titular": "Mariela Olvera Quintana",
        "anticipo_monto": 150.00,
        "admin_password": "0000",
        "horario_apertura": "14:00",
        "horario_cierre": "20:30",
        "dias_operativos": ["1", "2", "3", "4", "5", "6"]
    }'::jsonb)
ON CONFLICT (clave) DO UPDATE SET valor = EXCLUDED.valor;

-- Insertar Cupón Ejemplo Inicial
INSERT INTO public.cupones (codigo, tipo, valor, fecha_inicio, fecha_expiracion, activo)
VALUES ('BIENVENIDA10', 'porcentaje', 10.00, CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', true)
ON CONFLICT (codigo) DO NOTHING;

-- ====================================================================
-- HABILITAR ROW LEVEL SECURITY (RLS) Y POLÍTICAS DE ACCESO PÚBLICO
-- ====================================================================

ALTER TABLE public.servicios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cupones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bloqueos_agenda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.citas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracion ENABLE ROW LEVEL SECURITY;

-- Políticas de Lectura Pública (Permitir a clientes consultar catálogo, cupones y citas)
CREATE POLICY "Permitir lectura publica de servicios" ON public.servicios FOR SELECT USING (true);
CREATE POLICY "Permitir lectura publica de cupones" ON public.cupones FOR SELECT USING (true);
CREATE POLICY "Permitir lectura publica de bloqueos" ON public.bloqueos_agenda FOR SELECT USING (true);
CREATE POLICY "Permitir lectura publica de citas" ON public.citas FOR SELECT USING (true);
CREATE POLICY "Permitir lectura publica de configuracion" ON public.configuracion FOR SELECT USING (true);

-- Políticas de Inserción / Edición Pública para Clientes y Panel
CREATE POLICY "Permitir crear citas anonimo" ON public.citas FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir actualizar citas anonimo" ON public.citas FOR UPDATE USING (true);

CREATE POLICY "Permitir administrar servicios" ON public.servicios FOR ALL USING (true);
CREATE POLICY "Permitir administrar cupones" ON public.cupones FOR ALL USING (true);
CREATE POLICY "Permitir administrar bloqueos" ON public.bloqueos_agenda FOR ALL USING (true);
CREATE POLICY "Permitir administrar configuracion" ON public.configuracion FOR ALL USING (true);

-- Habilitar Publicaciones Realtime en Supabase
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE public.citas, public.bloqueos_agenda, public.servicios, public.cupones, public.configuracion;
COMMIT;
