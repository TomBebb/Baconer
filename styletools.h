#ifndef STYLETOOLS_H
#define STYLETOOLS_H

#include <QObject>

class StyleTools : public QObject
{
    Q_OBJECT
private:
    QString themeName;
public:
    explicit StyleTools(QObject *parent = nullptr);
    void checkTheme();

public slots:
    void setTheme(QString styleName);
    QString getTheme();
    QStringList getThemes();
signals:

};

#endif // STYLETOOLS_H
