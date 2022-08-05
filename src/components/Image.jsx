import React from 'react';

export default function ImageWithFallback({ fallback, src, fn, ...props}) {
    const [imgSrc, setImgSrc] = React.useState(src);
    const onError = () => setImgSrc(fallback);

    React.useEffect(() => {
        setImgSrc(src);
    }, [src]);

    return <img src={fn ? (imgSrc ? fn(imgSrc) : fallback) : (imgSrc ? imgSrc : fallback)} onError={onError} alt="" {...props} />;
}