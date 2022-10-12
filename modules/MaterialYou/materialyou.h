#ifndef MATERIALYOU_H
#define MATERIALYOU_H

#include <QObject>
#include <QtQml>
#include <QColor>
#include <QFont>

class MaterialYou : public QObject
{
    Q_OBJECT
    Q_PROPERTY(FontRole fontRole READ fontRole WRITE setFontRole NOTIFY fontRoleChanged)
    Q_PROPERTY(int radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(int elevation READ elevation WRITE setElevation NOTIFY elevationChanged)
    Q_PROPERTY(int animDuration READ animDuration WRITE setAnimDuration NOTIFY animDurationChanged)
    Q_PROPERTY(QVariant backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(QVariant foregroundColor READ foregroundColor WRITE setForegroundColor NOTIFY foregroundColorChanged)

public:
    enum Theme {
        System,
        Light,
        Dark,
    };
    Q_ENUM(Theme)

    enum ColorRole {
        Primary,
        OnPrimary,
        PrimaryContainer,
        OnPrimaryContainer,
        Secondary,
        OnSecondary,
        SecondaryContainer,
        OnSecondaryContainer,
        Tertiary,
        OnTertiary,
        TertiaryContainer,
        OnTertiaryContainer,
        Error,
        ErrorContainer,
        OnError,
        OnErrorContainer,
        Background,
        OnBackground,
        Surface,
        OnSurface,
        SurfaceVariant,
        OnSurfaceVariant,
        Outline,
        OutlineVariant,
        InverseOnSurface,
        InverseSurface,
        InversePrimary,
        Shadow,
        SurfaceTint,
        SurfaceTintColor,
        Transparent,
    };
    Q_ENUM(ColorRole)

    enum FontRole {
        LabelSmall,
        LabelMedium,
        LabelLarge,
        BodySmall,
        BodyMedium,
        BodyLarge,
        HeadlineSmall,
        HeadlineMedium,
        HeadlineLarge,
        DisplaySmall,
        DisplayMedium,
        DisplayLarge,
        TitleSmall,
        TitleMedium,
        TitleLarge,
    };
    Q_ENUM(FontRole)

    enum StateRole {
        Normal,
        Hover,
        Focus,
        Press,
        Dragging,
    };
    Q_ENUM(StateRole)

public:
    Q_INVOKABLE QColor color(const QVariant& c) const;
    Q_INVOKABLE QColor tintSurfaceColor(int layer) const;
    Q_INVOKABLE QFont font(MaterialYou::FontRole role) const;
    Q_INVOKABLE qreal lineHeight(MaterialYou::FontRole role) const;
    Q_INVOKABLE MaterialYou::ColorRole onFromBackground(MaterialYou::ColorRole role) const;

public:
    explicit MaterialYou(QObject *parent = nullptr);

    static MaterialYou *qmlAttachedProperties(QObject *object);



    FontRole fontRole() const;
    void setFontRole(FontRole newFontRole);

    int radius() const;
    void setRadius(int newRadius);

    int elevation() const;
    void setElevation(int newElevation);

    const QColor &backgroundColor() const;
    void setBackgroundColor(const QVariant &newBackgroundColor);

    const QColor &foregroundColor() const;
    void setForegroundColor(const QVariant &newForegroundColor);

    int animDuration() const;
    void setAnimDuration(int newAnimDuration);

signals:

    void fontRoleChanged();

    void radiusChanged();

    void elevationChanged();

    void backgroundColorChanged();

    void foregroundColorChanged();

    void animDurationChanged();

private:
    bool m_isDarkSystemTheme() const;

private:
    FontRole m_fontRole;
    int m_radius = 0;
    int m_elevation = 0;
    QColor m_backgroundColor;
    QColor m_foregroundColor;
    int m_animDuration;
};

QML_DECLARE_TYPEINFO(MaterialYou, QML_HAS_ATTACHED_PROPERTIES)

#endif // MATERIALYOU_H
