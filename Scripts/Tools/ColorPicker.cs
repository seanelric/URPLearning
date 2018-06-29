/// <summary>
/// Author: Sean.Yu
/// </summary>
using UnityEngine;
using System.Collections;

namespace Michelle
{
    public class ColorPicker : MonoBehaviour
    {
        Camera m_camera;
        BoxCollider m_pickerCollider;

        bool m_grap;
        Vector3 m_pixelPosition = Vector3.zero;
        Color m_pickedColor = Color.white;

        // Color rect
        Texture2D m_colorRectTexture;
        GUIStyle m_colorRectStyle;

        void Awake()
        {
            m_camera = GetComponent<Camera>();
            if (m_camera == null)
            {
                Debug.LogError("Please drag this script to a camera!");
                return;
            }

            // Attach a box collider to this camera,
            // in order to receive mouse events.
            if (m_pickerCollider == null)
            {
                m_pickerCollider = gameObject.AddComponent<BoxCollider>();
                // Make sure the collider is in camera's frustum.
                m_pickerCollider.center = Vector3.zero;
                m_pickerCollider.center += m_camera.transform.worldToLocalMatrix.MultiplyVector(m_camera.transform.forward)
                    * (m_camera.nearClipPlane + 0.2f);
                m_pickerCollider.size = new Vector3(Screen.width, Screen.height, 0.1f);
            }
        }

        void OnGUI()
        {
            GUI.Box(new Rect(0, 0, 120, 210), "Color Picker");
            DrawColorRect(new Rect(20, 30, 80, 80), m_pickedColor);
            GUI.Label(new Rect(10, 120, 100, 20), "R: " + System.Math.Round((double)m_pickedColor.r, 4)
                + "\t(" + Mathf.FloorToInt(m_pickedColor.r * 255)+ ")");
            GUI.Label(new Rect(10, 140, 100, 20), "G: " + System.Math.Round((double)m_pickedColor.g, 4)
                + "\t(" + Mathf.FloorToInt(m_pickedColor.g * 255)+ ")");
            GUI.Label(new Rect(10, 160, 100, 20), "B: " + System.Math.Round((double)m_pickedColor.b, 4)
                + "\t(" + Mathf.FloorToInt(m_pickedColor.b * 255)+ ")");
            GUI.Label(new Rect(10, 180, 100, 20), "A: " + System.Math.Round((double)m_pickedColor.a, 4)
                + "\t(" + Mathf.FloorToInt(m_pickedColor.a * 255)+ ")");
        }

        void OnPostRender()
        {
            if (m_grap)
            {
                Texture2D screenRenderTexture = new Texture2D(Screen.width, Screen.height);
                screenRenderTexture.ReadPixels(new Rect(0f, 0f, Screen.width, Screen.height), 0, 0);
                screenRenderTexture.Apply();
                m_pickedColor = screenRenderTexture.GetPixel(Mathf.FloorToInt(m_pixelPosition.x),
                    Mathf.FloorToInt(m_pixelPosition.y));

                m_grap = false;
            }
        }

        void OnMouseDown()
        {
            m_grap = true;

            // Record the position of mouse to pick pixel
            m_pixelPosition = Input.mousePosition;
        }

        void DrawColorRect(Rect position, Color color)
        {
            if (m_colorRectTexture == null)
            {
                m_colorRectTexture = new Texture2D(1, 1);
            }
            if (m_colorRectStyle == null)
            {
                m_colorRectStyle = new GUIStyle();
            }

            m_colorRectTexture.SetPixel(0, 0, color);
            m_colorRectTexture.Apply();

            m_colorRectStyle.normal.background = m_colorRectTexture;

            GUI.Box(position, "", m_colorRectStyle);
        }
    }
}