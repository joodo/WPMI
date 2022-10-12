#include <QQmlProperty>
#include <QGuiApplication>
#include <QPalette>
#include <QSettings>

#include "materialyou.h"

#include <QDebug>

static const QRgb colorsLight[] = {
    0x715c00,  // primary-light
    0xffffff,  // on-primary-light
    0xffe17b,  // primary-container-light
    0x231b00,  // on-primary-container-light
    0x685e40,  // secondary-light
    0xffffff,  // on-secondary-light
    0xf0e2bb,  // secondary-container-light
    0x221b04,  // on-secondary-container-light
    0x45664c,  // tertiary-light
    0xffffff,  // on-tertiary-light
    0xc7eccb,  // tertiary-container-light
    0x01210d,  // on-tertiary-container-light
    0xba1a1a,  // error-light
    0xffdad6,  // error-container-light
    0xffffff,  // on-error-light
    0x410002,  // on-error-container-light
    0xfffbff,  // background-light
    0x1d1b16,  // on-background-light
    0xfffbff,  // surface-light
    0x1d1b16,  // on-surface-light
    0xeae2cf,  // surface-variant-light
    0x4b4639,  // on-surface-variant-light
    0x7d7767,  // outline-light
    0xcec6b4,  // outline-variant-light
    0xf6f0e7,  // inverse-on-surface-light
    0x33302a,  // inverse-surface-light
    0xe6c449,  // inverse-primary-light
    0x000000,  // shadow-light
    0x715c00,  // surface-tint-light
    0x715c00,  // surface-tint-color-light
};
static const QRgb colorsDark[] = {
    0xe6c449,  // primary-dark
    0x3b2f00,  // on-primary-dark
    0x564500,  // primary-container-dark
    0xffe17b,  // on-primary-container-dark
    0xd3c6a1,  // secondary-dark
    0x383016,  // on-secondary-dark
    0x4f462a,  // secondary-container-dark
    0xf0e2bb,  // on-secondary-container-dark
    0xabd0b0,  // tertiary-dark
    0x173721,  // on-tertiary-dark
    0x2e4e36,  // tertiary-container-dark
    0xc7eccb,  // on-tertiary-container-dark
    0xffb4ab,  // error-dark
    0x93000a,  // error-container-dark
    0x690005,  // on-error-dark
    0xffdad6,  // on-error-container-dark
    0x1d1b16,  // background-dark
    0xe8e2d9,  // on-background-dark
    0x1d1b16,  // surface-dark
    0xe8e2d9,  // on-surface-dark
    0x4b4639,  // surface-variant-dark
    0xcec6b4,  // on-surface-variant-dark
    0x979080,  // outline-dark
    0x4b4639,  // outline-variant-dark
    0x1d1b16,  // inverse-on-surface-dark
    0xe8e2d9,  // inverse-surface-dark
    0x715c00,  // inverse-primary-dark
    0x000000,  // shadow-dark
    0xe6c449,  // surface-tint-dark
    0xe6c449,  // surface-tint-color-dark
};

static const qreal fontPointSizes[] = {
    11.0,  // label-small
    12.0,  // label-medium
    14.0,  // label-large
    12.0,  // body-small
    14.0,  // body-medium
    16.0,  // body-large
    24.0,  // headline-small
    28.0,  // headline-medium
    32.0,  // headline-large
    36.0,  // display-small
    45.0,  // display-medium
    57.0,  // display-large
    14.0,  // title-small
    16.0,  // title-medium
    22.0,  // title-large
};
static const QFont::Weight fontWeight[] = {
    QFont::Medium,  // label-small
    QFont::Medium,  // label-medium
    QFont::Medium,  // label-large
    QFont::Normal,  // body-small
    QFont::Normal,  // body-medium
    QFont::Normal,  // body-large
    QFont::Normal,  // headline-small
    QFont::Normal,  // headline-medium
    QFont::Normal,  // headline-large
    QFont::Normal,  // display-small
    QFont::Normal,  // display-medium
    QFont::Normal,  // display-large
    QFont::Medium,  // title-small
    QFont::Medium,  // title-medium
    QFont::Normal,  // title-large
};
static const qreal fontLetterSpacing[] = {
    0.5,  // label-small
    0.5,  // label-medium
    0.1,  // label-large
    0.4,  // body-small
    0.25,  // body-medium
    0.5,  // body-large
    0.0,  // headline-small
    0.0,  // headline-medium
    0.0,  // headline-large
    0.0,  // display-small
    0.0,  // display-medium
    -0.25,  // display-large
    0.1,  // title-small
    0.15,  // title-medium
    0.0,  // title-large
};
static const qreal fontLineHeight[] = {
    1.45,  // label-small
    1.33,  // label-medium
    1.43,  // label-large
    1.33,  // body-small
    1.43,  // body-medium
    1.5,  // body-large
    1.33,  // headline-small
    1.29,  // headline-medium
    1.25,  // headline-large
    1.22,  // display-small
    1.16,  // display-medium
    1.12,  // display-large
    1.43,  // title-small
    1.5,  // title-medium
    1.27,  // title-large
};

QColor MaterialYou::color(const QVariant &c) const
{
    if (c.userType() != QMetaType::Int)
    {
        return c.value<QColor>();
    }

    auto role = c.value<MaterialYou::ColorRole>();

    // FIXME: clean it
    if (role == ColorRole::Transparent) return QColor("transparent");

    if (role < 0 || role >= sizeof(colorsDark) / sizeof(colorsDark[0])) return QColor();

    QSettings settings;
    auto settingTheme = settings.value("MaterialYou/theme").value<Theme>();
    switch (settingTheme)
    {
    case Theme::Light:
        return colorsLight[role];
    case Theme::Dark:
        return colorsDark[role];
    default:
        return QColor(m_isDarkSystemTheme()? colorsDark[role] : colorsLight[role]);
    }
}

QColor MaterialYou::tintSurfaceColor(int layer) const
{
    if (layer > 5) layer = 5;
    if (layer < 0) layer = 0;
    const qreal opacities[] = {0, 0.05, 0.08, 0.11, 0.12, 0.14};
    const QColor surfaceColor = this->color(ColorRole::Surface);
    const QColor primaryColor = this->color(ColorRole::SurfaceTint);
    const qreal a = opacities[layer];
    return QColor::fromRgbF(surfaceColor.redF()*(1.0-a) + primaryColor.redF()*a,
                            surfaceColor.greenF()*(1.0-a) + primaryColor.greenF()*a,
                            surfaceColor.blueF()*(1.0-a) + primaryColor.blueF()*a);
}

QFont MaterialYou::font(FontRole role) const
{
    if (role < 0 || role >= sizeof(fontPointSizes) / sizeof(fontPointSizes[0])) return QFont();
    auto font = qGuiApp->font();
    font.setPointSize(fontPointSizes[role]);
    font.setWeight(fontWeight[role]);
    font.setLetterSpacing(QFont::AbsoluteSpacing, fontLetterSpacing[role]);
    return font;
}

qreal MaterialYou::lineHeight(FontRole role) const
{
    if (role < 0 || role >= sizeof(fontPointSizes) / sizeof(fontPointSizes[0])) return 1;
    return fontLineHeight[role];
}

MaterialYou::ColorRole MaterialYou::onFromBackground(ColorRole role) const
{
    switch (role) {
    case ColorRole::Primary:
        return ColorRole::OnPrimary; break;
    case ColorRole::PrimaryContainer:
        return ColorRole::OnPrimaryContainer; break;
    case ColorRole::Secondary:
        return ColorRole::OnSecondary; break;
    case ColorRole::SecondaryContainer:
        return ColorRole::OnSecondaryContainer; break;
    case ColorRole::Tertiary:
        return ColorRole::OnTertiary; break;
    case ColorRole::TertiaryContainer:
        return ColorRole::OnTertiaryContainer; break;
    case ColorRole::Error:
        return ColorRole::OnError; break;
    case ColorRole::ErrorContainer:
        return ColorRole::OnErrorContainer; break;
    case ColorRole::Background:
        return ColorRole::OnBackground; break;
    case ColorRole::Surface:
        return ColorRole::OnSurface; break;
    case ColorRole::SurfaceVariant:
        return ColorRole::OnSurfaceVariant; break;
    default:
        return ColorRole::OnSurface;
    }
}

MaterialYou::MaterialYou(QObject *parent)
    : QObject{parent}
{

}

MaterialYou *MaterialYou::qmlAttachedProperties(QObject *object)
{
    return new MaterialYou(object);
}

MaterialYou::FontRole MaterialYou::fontRole() const
{
    return m_fontRole;
}

void MaterialYou::setFontRole(FontRole newFontRole)
{
    if (m_fontRole == newFontRole)
        return;
    m_fontRole = newFontRole;
    emit fontRoleChanged();
}

bool MaterialYou::m_isDarkSystemTheme() const
{
    const auto baseColor = qGuiApp->palette().base().color();
    return (baseColor.red() < 128) && (baseColor.green() < 128) && (baseColor.blue() < 128);
}

int MaterialYou::radius() const
{
    return m_radius;
}

void MaterialYou::setRadius(int newRadius)
{
    if (m_radius == newRadius)
        return;
    m_radius = newRadius;
    emit radiusChanged();
}

int MaterialYou::elevation() const
{
    return m_elevation;
}

void MaterialYou::setElevation(int newElevation)
{
    if (m_elevation == newElevation)
        return;
    m_elevation = newElevation;
    emit elevationChanged();
}

const QColor &MaterialYou::backgroundColor() const
{
    return m_backgroundColor;
}

void MaterialYou::setBackgroundColor(const QVariant &newBackgroundColor)
{
    QColor newColor;

    if (newBackgroundColor.userType() == QMetaType::Int)
    {
        newColor = color(newBackgroundColor.value<ColorRole>());
    }
    else
    {
        newColor = newBackgroundColor.value<QColor>();
    }
    if (m_backgroundColor == newColor)
        return;
    m_backgroundColor = newColor;
    emit backgroundColorChanged();
}

const QColor &MaterialYou::foregroundColor() const
{
    return m_foregroundColor;
}

void MaterialYou::setForegroundColor(const QVariant &newForegroundColor)
{
    QColor newColor;

    if (newForegroundColor.userType() == QMetaType::Int)
    {
        newColor = color(newForegroundColor.value<ColorRole>());
    }
    else
    {
        newColor = newForegroundColor.value<QColor>();
    }
    if (m_foregroundColor == newColor)
        return;
    m_foregroundColor = newColor;
    emit foregroundColorChanged();
}

int MaterialYou::animDuration() const
{
    return m_animDuration;
}

void MaterialYou::setAnimDuration(int newAnimDuration)
{
    if (m_animDuration == newAnimDuration)
        return;
    m_animDuration = newAnimDuration;
    emit animDurationChanged();
}
